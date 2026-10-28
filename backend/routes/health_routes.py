"""Endpoint status backend + info model."""
from flask import Blueprint, jsonify

from config import Config
from database import db
from services.model_loader import ModelUnavailable, registry

health_bp = Blueprint("health", __name__, url_prefix="/api")


@health_bp.get("/health")
def health():
    models = []
    model_error = None
    try:
        models = registry.available_models()
    except ModelUnavailable as exc:
        model_error = str(exc)

    return jsonify({
        "status": "ok" if models else "degraded",
        "service": "SleepWise Backend",
        "database": "up" if db.available() else "down",
        "models": models,
        "selected_model": registry.metadata.get("model_name"),
        "model_dir": str(Config.MODEL_DIR),
        "model_error": model_error,
    })


@health_bp.get("/models")
def list_models():
    try:
        return jsonify({"models": registry.available_models(),
                        "metadata": registry.metadata})
    except ModelUnavailable as exc:
        return jsonify({"error": str(exc), "models": []}), 503
