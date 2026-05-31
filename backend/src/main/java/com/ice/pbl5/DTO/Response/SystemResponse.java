package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.SystemStatus;

import java.time.LocalDateTime;
import java.util.UUID;

public class SystemResponse {
    private UUID id;
    private String systemName;
    private String description;
    private String location;
    private SystemStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public SystemResponse() {
    }

    public SystemResponse(UUID id, String systemName, String description, String location, SystemStatus status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.systemName = systemName;
        this.description = description;
        this.location = location;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getSystemName() {
        return systemName;
    }

    public void setSystemName(String systemName) {
        this.systemName = systemName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public SystemStatus getStatus() {
        return status;
    }

    public void setStatus(SystemStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
