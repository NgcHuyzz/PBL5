package com.ice.pbl5.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ice.pbl5.DTO.Request.WebSocketMessageRequest;
import com.ice.pbl5.DTO.Response.WebSocketMessageResponse;
import com.ice.pbl5.Entity.Detection;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.Locale;
import java.util.UUID;

@Service
public class DeviceWebSocketHandler extends TextWebSocketHandler {
    private static final Path WS_IMAGE_DIR = Path.of("uploads", "images", "ws");
    private static final String DEFAULT_DEVICE_ID = "RASPBERRY_PI";
    private static final int WS_TEXT_MESSAGE_LIMIT_BYTES = 16 * 1024 * 1024; // 16MB

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final WebSocketSessionService webSocketSessionService;
    private final DetectionService detectionService;

    public DeviceWebSocketHandler(WebSocketSessionService webSocketSessionService, DetectionService detectionService) {
        this.webSocketSessionService = webSocketSessionService;
        this.detectionService = detectionService;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        session.setTextMessageSizeLimit(WS_TEXT_MESSAGE_LIMIT_BYTES);
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        WebSocketMessageRequest request;
        try {
            request = objectMapper.readValue(message.getPayload(), WebSocketMessageRequest.class);
        } catch (Exception e) {
            sendError(session, null, null, "Invalid JSON payload");
            return;
        }

        String type = normalize(request.getType());
        switch (type) {
            case "register" -> handleRegister(session, request);
            case "predict" -> handlePredict(session, request);
            default -> sendError(session, request.getSystemId(), request.getRequestId(), "Unsupported message type: " + type);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        webSocketSessionService.removeSession(session);
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        webSocketSessionService.removeSession(session);
        if (session.isOpen()) {
            session.close(CloseStatus.SERVER_ERROR);
        }
    }

    private void handleRegister(WebSocketSession session, WebSocketMessageRequest request) throws IOException {
        if (request.getSystemId() == null) {
            sendError(session, null, request.getRequestId(), "systemId is required for register");
            return;
        }

        webSocketSessionService.register(request.getSystemId(), session);

        WebSocketMessageResponse response = new WebSocketMessageResponse();
        response.setType("register");
        response.setSystemId(request.getSystemId());
        response.setStatus("success");
        sendMessage(session, response);
    }

    private void handlePredict(WebSocketSession session, WebSocketMessageRequest request) throws IOException {
        if (request.getSystemId() == null) {
            sendError(session, null, request.getRequestId(), "systemId is required for predict");
            return;
        }
        if (isBlank(request.getRequestId())) {
            sendError(session, request.getSystemId(), null, "requestId is required for predict");
            return;
        }
        if (isBlank(request.getImageBase64())) {
            sendError(session, request.getSystemId(), request.getRequestId(), "imageBase64 is required for predict");
            return;
        }

        DecodedImage decodedImage;
        try {
            decodedImage = decodeBase64Image(request.getImageBase64());
        } catch (IllegalArgumentException e) {
            sendError(session, request.getSystemId(), request.getRequestId(), "imageBase64 is invalid");
            return;
        }

        Path savedImagePath;
        try {
            savedImagePath = saveImageToDisk(request.getSystemId(), request.getRequestId(), decodedImage);
        } catch (IOException e) {
            sendError(session, request.getSystemId(), request.getRequestId(), "Cannot save image: " + e.getMessage());
            return;
        }

        webSocketSessionService.register(request.getSystemId(), session);

        Detection detection;
        try {
            detection = detectionService.createDetection(
                    request.getRequestId(),
                    request.getSystemId(),
                    DEFAULT_DEVICE_ID,
                    savedImagePath.toString()
            );
        } catch (Exception e) {
            sendError(session, request.getSystemId(), request.getRequestId(), "Cannot create detection: " + e.getMessage());
            return;
        }

        WebSocketMessageResponse response = new WebSocketMessageResponse();
        response.setType("accepted");
        response.setSystemId(request.getSystemId());
        response.setRequestId(request.getRequestId());
        response.setStatus("processing");
        sendMessage(session, response);
    }

    private void sendError(WebSocketSession session, UUID systemId, String requestId, String message) throws IOException {
        WebSocketMessageResponse error = new WebSocketMessageResponse();
        error.setType("error");
        error.setSystemId(systemId);
        error.setRequestId(requestId);
        error.setStatus("failed");
        error.setMessage(message);
        sendMessage(session, error);
    }

    private void sendMessage(WebSocketSession session, WebSocketMessageResponse response) throws IOException {
        if (!session.isOpen()) {
            return;
        }
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    private DecodedImage decodeBase64Image(String imageBase64) {
        String value = imageBase64.trim();
        String extension = "jpg";

        if (value.startsWith("data:")) {
            int commaIdx = value.indexOf(',');
            if (commaIdx < 0) {
                throw new IllegalArgumentException("Invalid data URI");
            }

            String header = value.substring(0, commaIdx).toLowerCase(Locale.ROOT);
            if (header.contains("image/png")) {
                extension = "png";
            } else if (header.contains("image/webp")) {
                extension = "webp";
            }
            value = value.substring(commaIdx + 1);
        }

        return new DecodedImage(Base64.getDecoder().decode(value), extension);
    }

    private Path saveImageToDisk(UUID systemId, String requestId, DecodedImage decodedImage) throws IOException {
        Path systemDir = WS_IMAGE_DIR.resolve(systemId.toString());
        Files.createDirectories(systemDir);

        String safeRequestId = requestId.replaceAll("[^a-zA-Z0-9_-]", "_");
        if (safeRequestId.isBlank()) {
            safeRequestId = UUID.randomUUID().toString();
        }

        String fileName = System.currentTimeMillis() + "-" + safeRequestId + "." + decodedImage.extension();
        Path outputFile = systemDir.resolve(fileName);
        Files.write(outputFile, decodedImage.bytes());
        return outputFile.toAbsolutePath().normalize();
    }

    private record DecodedImage(byte[] bytes, String extension) {
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
