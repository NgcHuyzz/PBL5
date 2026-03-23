package com.ice.pbl5.DTO.Response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class DetectionResponse {
    private UUID id;
    private String fruitType;
    private BigDecimal confidence;
    private String targetBin;
    private LocalDateTime classifiedAt;
    private String imageUrl;

    public DetectionResponse() {
    }

    public DetectionResponse(UUID id, String fruitType, BigDecimal confidence, String targetBin, LocalDateTime classifiedAt, String imageUrl) {
        this.id = id;
        this.fruitType = fruitType;
        this.confidence = confidence;
        this.targetBin = targetBin;
        this.classifiedAt = classifiedAt;
        this.imageUrl = imageUrl;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public LocalDateTime getClassifiedAt() {
        return classifiedAt;
    }

    public void setClassifiedAt(LocalDateTime classifiedAt) {
        this.classifiedAt = classifiedAt;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}
