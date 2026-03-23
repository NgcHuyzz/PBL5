package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.SystemControlRequest;
import com.ice.pbl5.DTO.Response.SystemResponse;
import com.ice.pbl5.Enum.SystemStatus;

import java.util.List;
import java.util.UUID;

public interface SystemService {
    List<SystemResponse> getMySystems(String username);
    SystemStatus controlSystem(UUID systemId, SystemControlRequest request, String username);
    SystemStatus getControlState(UUID systemId, String username);
}
