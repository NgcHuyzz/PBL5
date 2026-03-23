package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.DeviceStatusResponse;
import com.ice.pbl5.DTO.Response.SystemStatusResponse;

import java.util.List;
import java.util.UUID;

public interface SystemStatusService {
    SystemStatusResponse getSystemStatus(UUID systemId, String username);
    List<DeviceStatusResponse> getDeviceStatuses(UUID systemId, String username);
}
