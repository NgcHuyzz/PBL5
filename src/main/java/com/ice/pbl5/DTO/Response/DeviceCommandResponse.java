package com.ice.pbl5.DTO.Response;

import java.time.LocalDateTime;

public class DeviceCommandResponse {
    private boolean success;
    private String message;
    private LocalDateTime acknowledgedAt;

    public DeviceCommandResponse() {
    }

    public DeviceCommandResponse(boolean success, String message, LocalDateTime acknowledgedAt) {
        this.success = success;
        this.message = message;
        this.acknowledgedAt = acknowledgedAt;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getAcknowledgedAt() {
        return acknowledgedAt;
    }

    public void setAcknowledgedAt(LocalDateTime acknowledgedAt) {
        this.acknowledgedAt = acknowledgedAt;
    }
}
