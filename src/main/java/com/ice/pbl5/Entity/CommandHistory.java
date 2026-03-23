package com.ice.pbl5.Entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "command_history")
public class CommandHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "command_type", nullable = false)
    private String commandType;

    @Column(name = "target_bin")
    private String targetBin;

    @Column(name = "command_payload", columnDefinition = "TEXT")
    private String commandPayload;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    @Column(name = "response_status")
    private String responseStatus;

    @Column(name = "response_message")
    private String responseMessage;

    @Column(name = "acknowledged_at")
    private LocalDateTime acknowledgedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "system_id", nullable = false)
    private System system;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "detection_id", nullable = false)
    private Detection detection;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCommandType() {
        return commandType;
    }

    public void setCommandType(String commandType) {
        this.commandType = commandType;
    }

    public String getTargetBin() {
        return targetBin;
    }

    public void setTargetBin(String targetBin) {
        this.targetBin = targetBin;
    }

    public String getCommandPayload() {
        return commandPayload;
    }

    public void setCommandPayload(String commandPayload) {
        this.commandPayload = commandPayload;
    }

    public LocalDateTime getSentAt() {
        return sentAt;
    }

    public void setSentAt(LocalDateTime sentAt) {
        this.sentAt = sentAt;
    }

    public String getResponseStatus() {
        return responseStatus;
    }

    public void setResponseStatus(String responseStatus) {
        this.responseStatus = responseStatus;
    }

    public String getResponseMessage() {
        return responseMessage;
    }

    public void setResponseMessage(String responseMessage) {
        this.responseMessage = responseMessage;
    }

    public LocalDateTime getAcknowledgedAt() {
        return acknowledgedAt;
    }

    public void setAcknowledgedAt(LocalDateTime acknowledgedAt) {
        this.acknowledgedAt = acknowledgedAt;
    }

    public System getSystem() {
        return system;
    }

    public void setSystem(System system) {
        this.system = system;
    }

    public Detection getDetection() {
        return detection;
    }

    public void setDetection(Detection detection) {
        this.detection = detection;
    }
}
