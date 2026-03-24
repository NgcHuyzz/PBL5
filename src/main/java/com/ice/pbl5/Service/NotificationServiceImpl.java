package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.MarkReadResponse;
import com.ice.pbl5.DTO.Response.NotificationResponse;
import com.ice.pbl5.DTO.Response.PageResponse;
import com.ice.pbl5.DTO.Response.ReadAllResponse;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Entity.Notification;
import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Enum.NotificationLevel;
import com.ice.pbl5.Repository.NotificationRepo;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class NotificationServiceImpl implements NotificationService{

    private final NotificationRepo notificationRepo;
    private final SystemAccessService systemAccessService;

    public NotificationServiceImpl(NotificationRepo notificationRepo, SystemAccessService systemAccessService) {
        this.notificationRepo = notificationRepo;
        this.systemAccessService = systemAccessService;
    }

    @Override
    public PageResponse<NotificationResponse> getNotification(UUID systemId,NotificationLevel level, Integer page, Integer size, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        int actualPage = (page == null || page < 0) ? 0 : page;
        int actualSize = (size == null || size <= 0) ? 10 : size;

        Page<Notification> pageNotifications;

        if(level == null)
            pageNotifications = notificationRepo.findAllBySystem_IdAndSystem_User_UsernameOrderByCreatedAtDesc(system.getId(), username,PageRequest.of(actualPage, actualSize));
        else
            pageNotifications = notificationRepo.findBySystem_IdAndSystem_User_UsernameAndLevelOrderByCreatedAtDesc(system.getId(), username,level, PageRequest.of(actualPage, actualSize));

        List<NotificationResponse> content = pageNotifications.getContent().stream()
                .map(notification -> new NotificationResponse(
                        notification.getId(),
                        notification.getDetection().getId(),
                        notification.getLevel(),
                        notification.getTitle(),
                        notification.getMessage(),
                        notification.getRead(),
                        notification.getCreatedAt(),
                        notification.getReadAt()
                )).toList() ;

        return new PageResponse<NotificationResponse>(
                content,
                pageNotifications.getNumber(),
                pageNotifications.getSize(),
                pageNotifications.getTotalElements(),
                pageNotifications.getTotalPages()
        );
    }

    @Override
    public MarkReadResponse markAsRead(UUID id, UUID systemId, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        Notification notification = notificationRepo.findByIdAndSystem_IdAndSystem_User_Username(id, system.getId(), username)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));

        if(Boolean.FALSE.equals(notification.getRead()))
        {
            notification.setRead(Boolean.TRUE);
            notification.setReadAt(LocalDateTime.now());
            notificationRepo.save(notification);
        }

        return new MarkReadResponse(
                notification.getId(),
                notification.getRead(),
                notification.getReadAt()
        );
    }

    @Override
    public ReadAllResponse markAllAsRead(UUID systemId, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        List<Notification> notifications = notificationRepo.findBySystem_IdAndSystem_User_UsernameAndIsReadFalse(system.getId(), username);

        LocalDateTime now = LocalDateTime.now();

        notifications.forEach(n -> {
            n.setRead(Boolean.TRUE);
            n.setReadAt(now);
        });

        notificationRepo.saveAll(notifications);

        return new ReadAllResponse(notifications.size(), now);
    }

    @Override
    public long getUnreadCount(UUID systemId, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        return notificationRepo.countBySystem_IdAndSystem_User_UsernameAndIsReadFalse(system.getId(), username);
    }

    @Override
    public void createNotification(Detection detection, NotificationLevel level, String title, String message) {
        Notification notification = new Notification();
        notification.setSystem(detection.getSystem());
        notification.setDetection(detection);
        notification.setLevel(level);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setCreatedAt(LocalDateTime.now());

        notificationRepo.save(notification);
    }
}
