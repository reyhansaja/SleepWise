"""Konfigurasi backend Flask SleepWise (dibaca dari .env)."""
import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent
PROJECT_DIR = BASE_DIR.parent
load_dotenv(BASE_DIR / ".env")


def _path(env_key: str, default: Path) -> Path:
    raw = os.getenv(env_key)
    if not raw:
        return default
    p = Path(raw)
    return p if p.is_absolute() else (BASE_DIR / p).resolve()


class Config:
    HOST = os.getenv("FLASK_HOST", "127.0.0.1")
    PORT = int(os.getenv("FLASK_PORT", "5000"))
    DEBUG = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", "*").split(",") if o.strip()]

    MYSQL_HOST = os.getenv("MYSQL_HOST", "127.0.0.1")
    MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
    MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "sleepwise")
    MYSQL_USER = os.getenv("MYSQL_USER", "root")
    MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "")

    # Artefak ML: pipeline terpilih hasil 04_model_selection.py
    MODEL_DIR = _path("MODEL_DIR", PROJECT_DIR / "ml" / "models")
    UPLOAD_DIR = _path("UPLOAD_DIR", BASE_DIR / "uploads")
    DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "selected")  # selected|random_forest|decision_tree

    MAX_UPLOAD_BYTES = int(os.getenv("MAX_UPLOAD_BYTES", str(10 * 1024 * 1024)))
    MAX_UPLOAD_ROWS = int(os.getenv("MAX_UPLOAD_ROWS", "200000"))
    # Bila diisi, endpoint training wajib header X-Training-Token
    TRAINING_TOKEN = os.getenv("TRAINING_TOKEN", "")
