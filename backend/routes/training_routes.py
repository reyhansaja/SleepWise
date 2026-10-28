"""Endpoint ML Training: upload dataset, latih DT + RF, riwayat run, aktifkan model."""
from functools import wraps

from flask import Blueprint, jsonify, request

from config import Config
from services import training_service
from services.training_service import TrainingError

training_bp = Blueprint("training", __name__, url_prefix="/api/ml")


def require_token(view):
    """Bila TRAINING_TOKEN diset di .env, wajib header X-Training-Token."""

    @wraps(view)
    def wrapper(*args, **kwargs):
        if Config.TRAINING_TOKEN and request.headers.get("X-Training-Token") != Config.TRAINING_TOKEN:
            return jsonify({"error": "tidak berwenang"}), 401
        return view(*args, **kwargs)

    return wrapper


@training_bp.post("/upload")
@require_token
def upload():
    file = request.files.get("file")
    if file is None or not file.filename:
        return jsonify({"error": "kirim file CSV pada field 'file'"}), 400
    try:
        return jsonify(training_service.save_upload(file)), 201
    except TrainingError as exc:
        return jsonify({"error": str(exc)}), 400


@training_bp.get("/uploads")
def uploads():
    return jsonify({"data": training_service.list_uploads()})


@training_bp.post("/train")
@require_token
def train():
    payload = request.get_json(silent=True) or {}
    dataset_id = payload.get("dataset_id")
    if not dataset_id:
        return jsonify({"error": "dataset_id wajib diisi (hasil endpoint /api/ml/upload)"}), 400
    try:
        metadata = training_service.run_training(
            dataset_id,
            target_column=payload.get("target_column"),
            params=payload.get("params") or {},
        )
    except TrainingError as exc:
        return jsonify({"error": str(exc)}), 400
    except Exception as exc:  # noqa: BLE001
        return jsonify({"error": f"training gagal: {exc}"}), 500
    return jsonify(metadata), 201


@training_bp.get("/runs")
def runs():
    limit = min(max(request.args.get("limit", default=20, type=int) or 20, 1), 100)
    rows = training_service.list_runs(limit)
    return jsonify({"count": len(rows), "data": rows})


@training_bp.get("/runs/<run_id>")
def run_detail(run_id: str):
    metadata = training_service.get_run(run_id)
    if metadata is None:
        return jsonify({"error": "run tidak ditemukan"}), 404
    return jsonify(metadata)


@training_bp.post("/runs/<run_id>/promote")
@require_token
def promote(run_id: str):
    payload = request.get_json(silent=True) or {}
    model_key = payload.get("model_key", "random_forest")
    try:
        return jsonify(training_service.promote(run_id, model_key))
    except TrainingError as exc:
        return jsonify({"error": str(exc)}), 400
