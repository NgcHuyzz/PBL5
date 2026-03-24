package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import com.ice.pbl5.Entity.Detection;
import org.springframework.stereotype.Service;

@Service
public interface CommandService {
    public DeviceCommandResponse executeSortCommand(Detection detection);
}
