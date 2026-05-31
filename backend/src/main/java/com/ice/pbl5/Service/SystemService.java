package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.SystemControlRequest;
import com.ice.pbl5.DTO.Request.SystemCreateRequest;
import com.ice.pbl5.DTO.Response.SystemResponse;
import com.ice.pbl5.DTO.Response.SystemStatusResponse;
import com.ice.pbl5.Enum.SystemStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.UUID;

public interface SystemService {
    List<SystemResponse> getMySystems(String username);
    SystemStatusResponse controlSystem(UUID systemId, SystemControlRequest request, String username);
    SystemStatusResponse getControlState(UUID systemId, String username);

    UUID register();
    SystemResponse addSystemInUser(SystemCreateRequest request, String username);
}
