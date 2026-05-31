package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.DeviceCommandRequest;
import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import com.ice.pbl5.Entity.CommandHistory;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Enum.CommandStatus;
import com.ice.pbl5.Enum.CommandType;
import com.ice.pbl5.Repository.CommandHistoryRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class CommandServiceImpl implements CommandService{

    private final DeviceControlService deviceControlService;
    private final CommandHistoryRepo commandHistoryRepo;

    public CommandServiceImpl(DeviceControlService deviceControlService, CommandHistoryRepo commandHistoryRepo) {
        this.deviceControlService = deviceControlService;
        this.commandHistoryRepo = commandHistoryRepo;
    }

    @Override
    public DeviceCommandResponse executeSortCommand(Detection detection, String requestId) {
        DeviceCommandRequest request = new DeviceCommandRequest(detection.getSystem().getId(), detection.getFruitType(), detection.getConfidence(), detection.getTargetBin());

        CommandHistory commandHistory = new CommandHistory();
        commandHistory.setDetection(detection);
        commandHistory.setSystem(detection.getSystem());
        commandHistory.setCommandType(CommandType.SORT);
        commandHistory.setTargetBin(detection.getTargetBin());
        commandHistory.setCommandPayload(toJson(request));
        commandHistory.setSentAt(LocalDateTime.now());
        commandHistory.setResponseStatus(CommandStatus.SENT);

        commandHistoryRepo.save(commandHistory);

        try
        {
            DeviceCommandResponse response = deviceControlService.sendSortCommand(request, requestId);
            commandHistory.setResponseMessage(response.getMessage());
            commandHistory.setResponseStatus(
                    response.isSuccess() ? CommandStatus.ACK_SUCCESS : CommandStatus.ACK_FAILED
            );
            commandHistory.setAcknowledgedAt(response.getAcknowledgedAt());
            commandHistoryRepo.save(commandHistory);
            return response;
        }
        catch (Exception e)
        {
            commandHistory.setAcknowledgedAt(LocalDateTime.now());
            commandHistory.setResponseStatus(CommandStatus.ERROR);
            commandHistory.setResponseMessage(e.getMessage());
            commandHistoryRepo.save(commandHistory);

            return new DeviceCommandResponse(false, e.getMessage(), LocalDateTime.now());
        }
    }

    @Override
    public DeviceCommandResponse executeControlCommand(System system, CommandType commandType) {

        CommandHistory commandHistory = new CommandHistory();
        commandHistory.setSystem(system);
        commandHistory.setCommandType(commandType);
        commandHistory.setSentAt(LocalDateTime.now());
        commandHistory.setResponseStatus(CommandStatus.SENT);

        commandHistoryRepo.save(commandHistory);

        try
        {
            DeviceCommandResponse response = deviceControlService.sendCommand(system.getId(), commandType.name());
            commandHistory.setResponseMessage(response.getMessage());
            commandHistory.setResponseStatus(
                    response.isSuccess() ? CommandStatus.ACK_SUCCESS : CommandStatus.ACK_FAILED
            );
            commandHistory.setAcknowledgedAt(response.getAcknowledgedAt());
            commandHistoryRepo.save(commandHistory);
            return response;
        }
        catch (Exception e)
        {
            commandHistory.setAcknowledgedAt(LocalDateTime.now());
            commandHistory.setResponseStatus(CommandStatus.ERROR);
            commandHistory.setResponseMessage(e.getMessage());
            commandHistoryRepo.save(commandHistory);

            return new DeviceCommandResponse(false, e.getMessage(), LocalDateTime.now());
        }
    }

    private String toJson(DeviceCommandRequest request) {
        try {
            return "{\"systemId\":\"" + request.getSystemId()
                    + "\",\"fruitType\":\"" + safeString(request.getFruitType())
                    + "\",\"confidence\":\"" + request.getConfidence()
                    + "\",\"targetBin\":\"" + safeString(request.getTargetBin()) + "\"}";
        } catch (Exception e) {
            return "{\"error\":\"Cannot serialize payload\"}";
        }
    }

    private String safeString(String value) {
        return value == null ? "" : value.replace("\"", "\\\"");
    }
}
