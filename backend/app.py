"""Entry point backend Flask SleepWise."""
import logging
import sys
from pathlib import Path

from flask import Flask, jsonify
from flask_cors import CORS

sys.path.insert(0, str(Path(__file__).resolve().parent))

from config import Config  # noqa: E402
from database import db  # noqa: E402
from routes.health_routes import health_bp  # noqa: E402
from routes.prediction_routes import prediction_bp  # noqa: E402
from routes.training_routes import training_bp  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")


def create_app() -> Flask:
    app = Flask(__name__)
    CORS(app, origins=Config.CORS_ORIGINS)

    app.register_blueprint(health_bp)
    app.register_blueprint(prediction_bp)
    app.register_blueprint(training_bp)

    if db.init_schema():
        logging.info("Skema MySQL siap (database: %s).", Config.MYSQL_DATABASE)
    else:
        logging.warning("MySQL tidak tersedia; prediksi tetap jalan tanpa penyimpanan riwayat.")

    @app.errorhandler(404)
    def not_found(_):
        return jsonify({"error": "endpoint tidak ditemukan"}), 404

    @app.errorhandler(405)
    def not_allowed(_):
        return jsonify({"error": "method tidak diizinkan"}), 405

    @app.errorhandler(500)
    def internal_error(exc):
        logging.exception("Kesalahan server: %s", exc)
        return jsonify({"error": "kesalahan internal server"}), 500

    return app


app = create_app()

if __name__ == "__main__":
    app.run(host=Config.HOST, port=Config.PORT, debug=Config.DEBUG)
