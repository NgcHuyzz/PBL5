package com.ice.pbl5.DTO.Response;

import java.time.LocalDateTime;
import java.util.UUID;

public class MarkReadResponse {
    private UUID id;
    private Boolean isRead;
    private LocalDateTime readAt;

    public MarkReadResponse() {
    }

    public MarkReadResponse(UUID id, Boolean isRead, LocalDateTime readAt) {
        this.id = id;
        this.isRead = isRead;
        this.readAt = readAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Boolean getRead() {
        return isRead;
    }

    public void setRead(Boolean read) {
        isRead = read;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }
}
