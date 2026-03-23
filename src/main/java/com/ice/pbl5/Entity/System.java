package com.ice.pbl5.Entity;

import com.ice.pbl5.Enum.SystemStatus;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "systems")
public class System {
    @Id
    @Column(name = "id")
    private UUID id;

    @Column(name = "system_name", nullable = false)
    private String systemName;

    @Column(name = "description")
    private String description;

    @Column(name = "location")
    private String location;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private SystemStatus status;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToMany(mappedBy = "system")
    private List<Detection> detections = new ArrayList<>();

    @OneToMany(mappedBy = "system")
    private List<CommandHistory> commandHistories = new ArrayList<>();

    @OneToMany(mappedBy = "system")
    private List<DeviceStatus> deviceStatuses = new ArrayList<>();

    @OneToMany(mappedBy = "system")
    private List<SystemLog> systemLogs = new ArrayList<>();

    @OneToMany(mappedBy = "system")
    private List<Notification> notifications = new ArrayList<>();

    @OneToMany(mappedBy = "system")
    private List<SystemControlHistory> systemControlHistories = new ArrayList<>();

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

    public String getSystemName() {
        return systemName;
    }

    public void setSystemName(String systemName) {
        this.systemName = systemName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public SystemStatus getStatus() {
        return status;
    }

    public void setStatus(SystemStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<Detection> getDetections() {
        return detections;
    }

    public void setDetections(List<Detection> detections) {
        this.detections = detections;
    }

    public List<CommandHistory> getCommandHistories() {
        return commandHistories;
    }

    public void setCommandHistories(List<CommandHistory> commandHistories) {
        this.commandHistories = commandHistories;
    }

    public List<DeviceStatus> getDeviceStatuses() {
        return deviceStatuses;
    }

    public void setDeviceStatuses(List<DeviceStatus> deviceStatuses) {
        this.deviceStatuses = deviceStatuses;
    }

    public List<SystemLog> getSystemLogs() {
        return systemLogs;
    }

    public void setSystemLogs(List<SystemLog> systemLogs) {
        this.systemLogs = systemLogs;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }

    public List<SystemControlHistory> getSystemControlHistories() {
        return systemControlHistories;
    }

    public void setSystemControlHistories(List<SystemControlHistory> systemControlHistories) {
        this.systemControlHistories = systemControlHistories;
    }
}
