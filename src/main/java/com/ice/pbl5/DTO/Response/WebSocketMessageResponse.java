package com.ice.pbl5.DTO.Response;

import java.math.BigDecimal;
import java.util.UUID;

public class WebSocketMessageResponse {
    private String type;
    private UUID systemId;
    private String requestId;
    private String status;
    private String message;

    private String fruitType;
    private BigDecimal confidence;
    private String targetBin;
    private String command;

    public WebSocketMessageResponse() {
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public UUID getSystemId() {
        return systemId;
    }

    public void setSystemId(UUID systemId) {
        this.systemId = systemId;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getFruitType() {
        return fruitType;
    }

    public void setFruitType(String fruitType) {
        this.fruitType = fruitType;
    }

    public BigDecimal getConfidence() {
        return confidence;
    }

    public void setConfidence(BigDecimal confidence) {
        this.confidence = confidence;
    }

    public String getTargetBin() {
        return targetBin;
    }

    public void setTargetBin(String targetBin) {
        this.targetBin = targetBin;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }
}
