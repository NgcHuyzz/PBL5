package com.ice.pbl5.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ice.pbl5.DTO.Request.DeviceCommandRequest;
import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import com.ice.pbl5.DTO.Response.WebSocketMessageResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class DeviceControlServiceImpl implements DeviceControlService {
    private final WebSocketSessionService webSocketSessionService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public DeviceControlServiceImpl(WebSocketSessionService webSocketSessionService) {
        this.webSocketSessionService = webSocketSessionService;
    }

    @Override
    public DeviceCommandResponse sendSortCommand(DeviceCommandRequest request, String requestId) {
        if (request == null || request.getSystemId() == null) {
            return new DeviceCommandResponse(false, "systemId is required", LocalDateTime.now());
        }

        WebSocketMessageResponse payload = new WebSocketMessageResponse();
        payload.setType("result");
        payload.setSystemId(request.getSystemId());
        payload.setRequestId(requestId);
        payload.setFruitType(request.getFruitType());
        payload.setTargetBin(request.getTargetBin());
        payload.setConfidence(request.getConfidence());

        return sendPayload(request.getSystemId(), payload);
    }

    @Override
    public DeviceCommandResponse sendCommand(UUID systemId, String command) {
        if (systemId == null) {
            return new DeviceCommandResponse(false, "systemId is required", LocalDateTime.now());
        }
        if (command == null || command.isBlank()) {
            return new DeviceCommandResponse(false, "command is required", LocalDateTime.now());
        }

        WebSocketMessageResponse payload = new WebSocketMessageResponse();
        payload.setType("command");
        payload.setSystemId(systemId);
        payload.setCommand(command.trim());
        return sendPayload(systemId, payload);
    }

    private DeviceCommandResponse sendPayload(UUID systemId, WebSocketMessageResponse payload) {
        WebSocketSession session = webSocketSessionService.getSession(systemId).orElse(null);
        if (session == null || !session.isOpen()) {
            return new DeviceCommandResponse(false, "Raspberry Pi is not connected", LocalDateTime.now());
        }

        try {
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(payload)));
            return new DeviceCommandResponse(true, "Command sent to device", LocalDateTime.now());
        } catch (IOException e) {
            webSocketSessionService.removeSession(session);
            return new DeviceCommandResponse(false, "Cannot send command: " + e.getMessage(), LocalDateTime.now());
        }
    }
}
