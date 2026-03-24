package com.ice.pbl5.DTO.Response;

import java.math.BigDecimal;

public class AiTCPResponse {
    private boolean success;
    private String fruitType;
    private BigDecimal confidence;
    private String message;

    public AiTCPResponse() {
    }

    public AiTCPResponse(boolean success, String fruitType, BigDecimal confidence, String message) {
        this.success = success;
        this.fruitType = fruitType;
        this.confidence = confidence;
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
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

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
