"""Autentikasi: register (role user), login email+kata sandi, profil, daftar user (admin)."""
import re

from flask import Blueprint, jsonify, request
from itsdangerous import BadSignature, SignatureExpired, URLSafeTimedSerializer
from werkzeug.security import check_password_hash, generate_password_hash

from config import Config
from database import db

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[A-Za-z]{2,}$")
_signer = URLSafeTimedSerializer(Config.SECRET_KEY, salt="sleepwise-auth")


def _error(message: str, code: int):
    return jsonify({"status": "error", "error": message}), code


def make_token(user: dict) -> str:
    return _signer.dumps({"uid": user["id"], "role": user["role"]})


def read_token(token: str):
    try:
        data = _signer.loads(token, max_age=Config.TOKEN_TTL_SECONDS)
    except (BadSignature, SignatureExpired):
        return None
    return data if isinstance(data, dict) and "uid" in data else None


def public_user(user: dict) -> dict:
    return {
        "id": user["id"],
        "nama_lengkap": user["full_name"],
        "email": user["email"],
        "role": user["role"],
    }


def current_user():
    """User dari header `Authorization: Bearer <token>`, atau None."""
    header = request.headers.get("Authorization", "")
    token = header[7:].strip() if header.lower().startswith("bearer ") else ""
    payload = read_token(token) if token else None
    if payload is None:
        return None
    return db.query_one(
        "SELECT id, full_name, email, role FROM users WHERE id = %s", (payload["uid"],)
    )


def _clean(payload: dict, *keys):
    for key in keys:
        value = payload.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return ""


@auth_bp.post("/register")
def register():
    payload = request.get_json(silent=True) or {}
    nama = _clean(payload, "nama_lengkap", "full_name", "nama")
    email = _clean(payload, "email").lower()
    sandi = str(payload.get("kata_sandi") or payload.get("password") or "")

    errors = []
    if len(nama) < 3:
        errors.append("nama lengkap minimal 3 karakter")
    if not _EMAIL_RE.match(email):
        errors.append("format email tidak valid")
    if len(sandi) < 8:
        errors.append("kata sandi minimal 8 karakter")
    if errors:
        return jsonify({"status": "error", "error": "validasi gagal", "details": errors}), 400

    if db.query_one("SELECT id FROM users WHERE email = %s", (email,)):
        return _error("email sudah terdaftar", 409)

    user_id = db.execute(
        "INSERT INTO users (full_name, email, password_hash, role) VALUES (%s, %s, %s, %s)",
        (nama, email, generate_password_hash(sandi), "user"),
    )
    if user_id is None:
        return _error("database tidak tersedia", 503)

    user = {"id": user_id, "full_name": nama, "email": email, "role": "user"}
    return jsonify({
        "status": "success",
        "message": "registrasi berhasil",
        "data": {**public_user(user), "token": make_token(user)},
    }), 201


@auth_bp.post("/login")
def login():
    payload = request.get_json(silent=True) or {}
    email = _clean(payload, "email").lower()
    sandi = str(payload.get("kata_sandi") or payload.get("password") or "")

    if not email or not sandi:
        return jsonify({
            "status": "error",
            "error": "validasi gagal",
            "details": ["email wajib diisi", "kata sandi wajib diisi"],
        }), 400

    user = db.query_one(
        "SELECT id, full_name, email, role, password_hash FROM users WHERE email = %s", (email,)
    )
    if user is None:
        return _error("email atau kata sandi salah", 401)
    if not check_password_hash(user["password_hash"], sandi):
        return _error("email atau kata sandi salah", 401)

    return jsonify({
        "status": "success",
        "message": "login berhasil",
        "data": {**public_user(user), "token": make_token(user)},
    })


@auth_bp.get("/me")
def me():
    user = current_user()
    if user is None:
        return _error("token tidak valid atau kedaluwarsa", 401)
    return jsonify({"status": "success", "data": public_user(user)})


@auth_bp.get("/users")
def list_users():
    user = current_user()
    if user is None:
        return _error("token tidak valid atau kedaluwarsa", 401)
    if user["role"] != "admin":
        return _error("khusus admin", 403)
    rows = db.query_all("SELECT id, full_name, email, role, created_at FROM users ORDER BY id")
    return jsonify({"status": "success", "count": len(rows), "data": rows})
