package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.DeviceCommandRequest;
import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public interface DeviceControlService {
    DeviceCommandResponse sendSortCommand(DeviceCommandRequest request, String requestId);
    DeviceCommandResponse sendCommand(UUID systemId, String command);
}
