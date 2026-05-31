package com.ice.pbl5.DTO.Response;

import java.time.LocalDateTime;

public class ReadAllResponse {
    private int updatedCount;
    private LocalDateTime readAt;

    public ReadAllResponse() {
    }

    public ReadAllResponse(int updatedCount, LocalDateTime readAt) {
        this.updatedCount = updatedCount;
        this.readAt = readAt;
    }

    public int getUpdatedCount() {
        return updatedCount;
    }

    public void setUpdatedCount(int updatedCount) {
        this.updatedCount = updatedCount;
    }

    public LocalDateTime getReadAt() {
        return readAt;
    }

    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }
}
