package com.ice.pbl5.DTO.Response;

public class AiTCPResponse {
    private boolean success;
    private String fruitType;
    private Double confidence;
    private String message;

    public AiTCPResponse() {
    }

    public AiTCPResponse(boolean success, String fruitType, Double confidence, String message) {
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

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
