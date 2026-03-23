package com.ice.pbl5.DTO.Response;

import com.ice.pbl5.Enum.DetectionStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class DetectionDetailResponse {
    private UUID id;
    private String deviceId;
    private String imageUrl;
    private String fruitType;
    private BigDecimal confidence;
    private String targetBin;
    private DetectionStatus status;
    private Integer aiProcessingTimeMs;
    private LocalDateTime createdAt;
    private LocalDateTime classifiedAt;
    private LocalDateTime completedAt;

    public DetectionDetailResponse() {
    }

    public DetectionDetailResponse(UUID id, String deviceId, String imageUrl, String fruitType, BigDecimal confidence, String targetBin, DetectionStatus status, Integer aiProcessingTimeMs, LocalDateTime createdAt, LocalDateTime classifiedAt, LocalDateTime completedAt) {
        this.id = id;
        this.deviceId = deviceId;
        this.imageUrl = imageUrl;
        this.fruitType = fruitType;
        this.confidence = confidence;
        this.targetBin = targetBin;
        this.status = status;
        this.aiProcessingTimeMs = aiProcessingTimeMs;
        this.createdAt = createdAt;
        this.classifiedAt = classifiedAt;
        this.completedAt = completedAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
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

    public DetectionStatus getStatus() {
        return status;
    }

    public void setStatus(DetectionStatus status) {
        this.status = status;
    }

    public Integer getAiProcessingTimeMs() {
        return aiProcessingTimeMs;
    }

    public void setAiProcessingTimeMs(Integer aiProcessingTimeMs) {
        this.aiProcessingTimeMs = aiProcessingTimeMs;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getClassifiedAt() {
        return classifiedAt;
    }

    public void setClassifiedAt(LocalDateTime classifiedAt) {
        this.classifiedAt = classifiedAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
}
