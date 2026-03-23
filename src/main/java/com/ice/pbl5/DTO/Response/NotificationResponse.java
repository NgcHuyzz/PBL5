package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.NotificationLevel;

import java.time.LocalDateTime;
import java.util.UUID;

public class NotificationResponse {
    private UUID id;
    private UUID detectionId;
    private NotificationLevel level;
    private String title;
    private String message;
    private Boolean isRead;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;

    public NotificationResponse() {
    }

    public NotificationResponse(UUID id, UUID detectionId, NotificationLevel level, String title, String message, Boolean isRead, LocalDateTime createdAt, LocalDateTime readAt) {
        this.id = id;
        this.detectionId = detectionId;
        this.level = level;
        this.title = title;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
        this.readAt = readAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getDetectionId() {
        return detectionId;
    }

    public void setDetectionId(UUID detectionId) {
        this.detectionId = detectionId;
    }

    public NotificationLevel getLevel() {
        return level;
    }

    public void setLevel(NotificationLevel level) {
        this.level = level;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Boolean getRead() {
        return isRead;
    }

    public void setRead(Boolean read) {
        isRead = read;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }
}
