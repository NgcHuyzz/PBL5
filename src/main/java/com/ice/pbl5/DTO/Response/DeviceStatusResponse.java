package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.DeviceState;

import java.time.LocalDateTime;

public class DeviceStatusResponse {
    private String deviceName;
    private DeviceState status;
    private LocalDateTime lastSeen;

    public DeviceStatusResponse() {
    }

    public DeviceStatusResponse(String deviceName, DeviceState status, LocalDateTime lastSeen) {
        this.deviceName = deviceName;
        this.status = status;
        this.lastSeen = lastSeen;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    public DeviceState getStatus() {
        return status;
    }

    public void setStatus(DeviceState status) {
        this.status = status;
    }

    public LocalDateTime getLastSeen() {
        return lastSeen;
    }

    public void setLastSeen(LocalDateTime lastSeen) {
        this.lastSeen = lastSeen;
    }
}
