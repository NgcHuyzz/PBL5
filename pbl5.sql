CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =========================
-- 1. USERS
-- =========================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- =========================
-- 2. SYSTEMS
-- =========================
CREATE TABLE systems (
    id UUID PRIMARY KEY,
    system_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    location VARCHAR(100),
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    user_id BIGINT,
    CONSTRAINT fk_system_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- =========================
-- 3. DETECTIONS
-- =========================
CREATE TABLE detections (
    id UUID PRIMARY KEY,
    device_id VARCHAR(50) NOT NULL,
    system_id UUID NOT NULL,
    image_url VARCHAR(255),
    fruit_type VARCHAR(50),
    confidence DECIMAL(5,4),
    target_bin VARCHAR(20),
    status VARCHAR(30) NOT NULL,
    ai_processing_time_ms INT,
    created_at TIMESTAMP NOT NULL,
	classified_at TIMESTAMP,
	completed_at TIMESTAMP,
	error_message VARCHAR(500),
    CONSTRAINT fk_detection_system
        FOREIGN KEY (system_id)
        REFERENCES systems(id)
        ON DELETE CASCADE
);

-- =========================
-- 4. COMMAND HISTORY
-- =========================
CREATE TABLE command_history (
    id BIGSERIAL PRIMARY KEY,
    detection_id UUID,
    system_id UUID NOT NULL,
    command_type VARCHAR(50) NOT NULL,
    target_bin VARCHAR(20),
    command_payload TEXT,
    sent_at TIMESTAMP NOT NULL,
    response_status VARCHAR(30),
    response_message VARCHAR(255),
    acknowledged_at TIMESTAMP,
    CONSTRAINT fk_command_detection
        FOREIGN KEY (detection_id)
        REFERENCES detections(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_command_system
        FOREIGN KEY (system_id)
        REFERENCES systems(id)
        ON DELETE CASCADE
);

-- =========================
-- 5. DEVICE STATUS
-- =========================
CREATE TABLE device_status (
    id BIGSERIAL PRIMARY KEY,
    system_id UUID,
    device_name VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL,
    last_seen TIMESTAMP,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_device_system
        FOREIGN KEY (system_id)
        REFERENCES systems(id)
        ON DELETE CASCADE
);

-- =========================
-- 6. SYSTEM LOGS
-- =========================
CREATE TABLE system_logs (
    id BIGSERIAL PRIMARY KEY,
    system_id UUID,
    detection_id UUID,
    source VARCHAR(50) NOT NULL,
    level VARCHAR(20) NOT NULL,
    message VARCHAR(500) NOT NULL,
    details TEXT,
    created_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_log_system
        FOREIGN KEY (system_id)
        REFERENCES systems(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_log_detection
        FOREIGN KEY (detection_id)
        REFERENCES detections(id)
        ON DELETE SET NULL
);

-- =========================
-- 7. NOTIFICATIONS
-- =========================
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    system_id UUID,
    detection_id UUID,
    level VARCHAR(20) NOT NULL,
    title VARCHAR(150) NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL,
    read_at TIMESTAMP,
    CONSTRAINT fk_notification_system
        FOREIGN KEY (system_id)
        REFERENCES systems(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_notification_detection
        FOREIGN KEY (detection_id)
        REFERENCES detections(id)
        ON DELETE SET NULL
);

-- =========================
-- 8. SYSTEM CONTROL HISTORY
-- =========================
CREATE TABLE system_control_history (
    id BIGSERIAL PRIMARY KEY,
    system_id UUID,
    action VARCHAR(30) NOT NULL,
    requested_by VARCHAR(50),
    request_payload TEXT,
    status VARCHAR(30) NOT NULL,
    executed_at TIMESTAMP NOT NULL,
    note VARCHAR(255),
    CONSTRAINT fk_control_system
        FOREIGN KEY (system_id)
        REFERENCES systems(id)
        ON DELETE CASCADE
);

-- =========================
-- 9. INDEXES
-- =========================
CREATE INDEX idx_systems_user_id ON systems(user_id);
CREATE INDEX idx_detections_system_id ON detections(system_id);
CREATE INDEX idx_command_history_detection_id ON command_history(detection_id);
CREATE INDEX idx_command_history_system_id ON command_history(system_id);
CREATE INDEX idx_device_status_system_id ON device_status(system_id);
CREATE INDEX idx_system_logs_system_id ON system_logs(system_id);
CREATE INDEX idx_system_logs_detection_id ON system_logs(detection_id);
CREATE INDEX idx_notifications_system_id ON notifications(system_id);
CREATE INDEX idx_notifications_detection_id ON notifications(detection_id);
CREATE INDEX idx_system_control_history_system_id ON system_control_history(system_id);

