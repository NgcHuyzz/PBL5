package com.ice.pbl5.DTO.Request;

import java.math.BigDecimal;
import java.util.UUID;

public class DeviceCommandRequest {
    private UUID systemId;
    private String fruitType;
    private BigDecimal confidence;
    private String targetBin;

    public DeviceCommandRequest() {
    }

    public DeviceCommandRequest(UUID systemId, String fruitType, BigDecimal confidence, String targetBin) {
        this.systemId = systemId;
        this.fruitType = fruitType;
        this.confidence = confidence;
        this.targetBin = targetBin;
    }

    public UUID getSystemId() {
        return systemId;
    }

    public void setSystemId(UUID systemId) {
        this.systemId = systemId;
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
}
