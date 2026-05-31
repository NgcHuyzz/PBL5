package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.SystemStatus;

public class SystemStatusResponse {
    private SystemStatus status;

    public SystemStatusResponse(SystemStatus status) {
        this.status = status;
    }

    public SystemStatusResponse() {
    }

    public SystemStatus getStatus() {
        return status;
    }

    public void setStatus(SystemStatus status) {
        this.status = status;
    }
}
