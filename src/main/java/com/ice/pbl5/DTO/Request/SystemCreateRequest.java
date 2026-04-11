package com.ice.pbl5.DTO.Request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public class SystemCreateRequest {
    @NotNull(message = "systemId is required")
    private UUID systemId;
    @NotBlank(message = "systemName is required")
    private String systemName;
    private String description;
    private String location;

    public SystemCreateRequest() {
    }

    public SystemCreateRequest(UUID systemId, String systemName, String description, String location) {
        this.systemId = systemId;
        this.systemName = systemName;
        this.description = description;
        this.location = location;
    }

    public UUID getSystemId() {
        return systemId;
    }

    public void setSystemId(UUID systemId) {
        this.systemId = systemId;
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
}
