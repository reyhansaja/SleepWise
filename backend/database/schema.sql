-- Skema database SleepWise (MySQL 8).
-- CREATE DATABASE sleepwise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS predictions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    gender VARCHAR(20) NULL,
    age TINYINT UNSIGNED NULL,
    occupation VARCHAR(100) NULL,
    sleep_duration DECIMAL(5,2) NULL,
    physical_activity_level SMALLINT UNSIGNED NULL,
    stress_level TINYINT UNSIGNED NULL,
    bmi_category VARCHAR(30) NULL,
    heart_rate SMALLINT UNSIGNED NULL,
    daily_steps INT UNSIGNED NULL,
    systolic_bp SMALLINT UNSIGNED NULL,
    diastolic_bp SMALLINT UNSIGNED NULL,
    sleep_disorder VARCHAR(50) NULL,
    predicted_quality VARCHAR(20) NOT NULL,
    confidence DECIMAL(6,4) NULL,
    model_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_predictions_created_at (created_at),
    INDEX idx_predictions_user_id (user_id)
);

CREATE TABLE IF NOT EXISTS prediction_recommendations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    prediction_id BIGINT UNSIGNED NOT NULL,
    category VARCHAR(50) NULL,
    message VARCHAR(500) NOT NULL,
    CONSTRAINT fk_recommendation_prediction
        FOREIGN KEY (prediction_id) REFERENCES predictions (id) ON DELETE CASCADE,
    INDEX idx_recommendation_prediction (prediction_id)
);

CREATE TABLE IF NOT EXISTS api_request_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    endpoint VARCHAR(100) NOT NULL,
    status_code SMALLINT NOT NULL,
    success TINYINT(1) NOT NULL,
    error_detail VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_api_log_created_at (created_at)
);

-- Riwayat training dari halaman web ML Training.
CREATE TABLE IF NOT EXISTS training_runs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    run_id VARCHAR(40) NOT NULL,
    dataset_filename VARCHAR(255) NULL,
    dataset_rows INT UNSIGNED NULL,
    target_column VARCHAR(100) NOT NULL,
    model_key VARCHAR(40) NOT NULL,
    model_name VARCHAR(60) NOT NULL,
    accuracy DECIMAL(8,6) NULL,
    f1_weighted DECIMAL(8,6) NULL,
    cv_f1_weighted DECIMAL(8,6) NULL,
    artifact_path VARCHAR(500) NULL,
    duration_ms INT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_training_runs_run_id (run_id),
    INDEX idx_training_runs_created_at (created_at)
);

