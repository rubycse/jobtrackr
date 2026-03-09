CREATE TABLE status_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    application_id BIGINT NOT NULL,
    old_status ENUM('SAVED', 'APPLIED', 'PHONE_SCREEN', 'TECHNICAL_SCREEN',
                     'TECHNICAL_INTERVIEW', 'BEHAVIORAL_INTERVIEW', 'ON_SITE',
                     'FINAL_ROUND', 'OFFER', 'REJECTED', 'WITHDRAWN'),
    new_status ENUM('SAVED', 'APPLIED', 'PHONE_SCREEN', 'TECHNICAL_SCREEN',
                     'TECHNICAL_INTERVIEW', 'BEHAVIORAL_INTERVIEW', 'ON_SITE',
                     'FINAL_ROUND', 'OFFER', 'REJECTED', 'WITHDRAWN') NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id BIGINT,
    CONSTRAINT fk_status_history_application FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    CONSTRAINT fk_status_history_user FOREIGN KEY (changed_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_status_history_application_id ON status_history(application_id);
