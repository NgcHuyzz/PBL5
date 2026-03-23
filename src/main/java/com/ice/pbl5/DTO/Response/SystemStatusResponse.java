package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.DeviceState;
import com.ice.pbl5.Enum.SystemStatus;

import java.time.LocalDateTime;

public class SystemStatusResponse {
    private SystemStatus systemStatus;
    private DeviceState conveyorStatus;
    private DeviceState cameraStatus;
    private DeviceState aiWorkerStatus;
    private LocalDateTime lastUpdated;

    public SystemStatusResponse() {
    }

    public SystemStatusResponse(SystemStatus systemStatus, DeviceState conveyorStatus, DeviceState cameraStatus, DeviceState aiWorkerStatus, LocalDateTime lastUpdated) {
        this.systemStatus = systemStatus;
        this.conveyorStatus = conveyorStatus;
        this.cameraStatus = cameraStatus;
        this.aiWorkerStatus = aiWorkerStatus;
        this.lastUpdated = lastUpdated;
    }

    public SystemStatus getSystemStatus() {
        return systemStatus;
    }

    public void setSystemStatus(SystemStatus systemStatus) {
        this.systemStatus = systemStatus;
    }

    public DeviceState getConveyorStatus() {
        return conveyorStatus;
    }

    public void setConveyorStatus(DeviceState conveyorStatus) {
        this.conveyorStatus = conveyorStatus;
    }

    public DeviceState getCameraStatus() {
        return cameraStatus;
    }

    public void setCameraStatus(DeviceState cameraStatus) {
        this.cameraStatus = cameraStatus;
    }

    public DeviceState getAiWorkerStatus() {
        return aiWorkerStatus;
    }

    public void setAiWorkerStatus(DeviceState aiWorkerStatus) {
        this.aiWorkerStatus = aiWorkerStatus;
    }

    public LocalDateTime getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(LocalDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}
