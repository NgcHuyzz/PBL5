package com.ice.pbl5.Entity;

import com.ice.pbl5.Enum.DetectionStatus;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "detections")
public class Detection {
    @Id
    @Column(name = "id")
    private UUID id;

    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "fruit_type")
    private String fruitType;

    @Column(name = "confidence", precision = 5, scale = 4)
    private BigDecimal confidence;

    @Column(name = "target_bin")
    private String targetBin;

    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    private DetectionStatus status;

    @Column(name = "ai_processing_time_ms")
    private Integer aiProcessingTimeMs;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "classified_at")
    private LocalDateTime classifiedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "error_message")
    private String errorMessage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "system_id", nullable = false)
    private System system;

    @OneToMany(mappedBy = "detection")
    private List<CommandHistory> commandHistories = new ArrayList<>();

    @OneToMany(mappedBy = "detection")
    private List<Notification> notifications = new ArrayList<>();

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    @PrePersist
    public void prePersist()
    {
        if(id == null)
            id = UUID.randomUUID();
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

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public System getSystem() {
        return system;
    }

    public void setSystem(System system) {
        this.system = system;
    }

    public List<CommandHistory> getCommandHistories() {
        return commandHistories;
    }

    public void setCommandHistories(List<CommandHistory> commandHistories) {
        this.commandHistories = commandHistories;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }
}
