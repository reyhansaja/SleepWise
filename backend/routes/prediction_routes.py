"""Endpoint prediksi kualitas tidur, riwayat, dan rekomendasi."""
from flask import Blueprint, jsonify, request

from database import db
from services import prediction_service
from services.model_loader import ModelUnavailable

prediction_bp = Blueprint("predictions", __name__, url_prefix="/api/predictions")


@prediction_bp.post("")
def create():
    payload = request.get_json(silent=True)
    data, errors = prediction_service.normalize(payload if payload is not None else {})
    if errors:
        db.execute(
            "INSERT INTO api_request_log (endpoint, status_code, success, error_detail) VALUES (%s, %s, %s, %s)",
            ("POST /api/predictions", 400, False, "; ".join(errors)[:500]),
        )
        return jsonify({"status": "error", "error": "validasi gagal", "details": errors}), 400

    try:
        result = prediction_service.create_prediction(data, (payload or {}).get("model"))
    except ModelUnavailable as exc:
        return jsonify({"status": "error", "error": str(exc)}), 503
    except ValueError as exc:
        return jsonify({"status": "error", "error": str(exc)}), 400

    db.execute(
        "INSERT INTO api_request_log (endpoint, status_code, success) VALUES (%s, %s, %s)",
        ("POST /api/predictions", 201, True),
    )
    return jsonify(result), 201


@prediction_bp.get("")
def history():
    limit = min(max(request.args.get("limit", default=50, type=int) or 50, 1), 200)
    user_id = request.args.get("user_id", type=int)
    rows = prediction_service.list_predictions(limit=limit, user_id=user_id)
    return jsonify({"count": len(rows), "data": rows})


@prediction_bp.get("/<int:prediction_id>")
def detail(prediction_id: int):
    row = prediction_service.get_prediction(prediction_id)
    if row is None:
        return jsonify({"error": "prediksi tidak ditemukan"}), 404
    return jsonify(row)


@prediction_bp.get("/<int:prediction_id>/recommendations")
def recommendations(prediction_id: int):
    if prediction_service.get_prediction(prediction_id) is None:
        return jsonify({"error": "prediksi tidak ditemukan"}), 404
    items = prediction_service.list_recommendations(prediction_id)
    return jsonify({"prediction_id": prediction_id, "count": len(items), "data": items})
