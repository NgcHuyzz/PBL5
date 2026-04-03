package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Enum.CommandType;
import org.springframework.stereotype.Service;

@Service
public interface CommandService {
    public DeviceCommandResponse executeSortCommand(Detection detection, String requestId);
    public DeviceCommandResponse executeControlCommand(System system, CommandType commandType);
}
