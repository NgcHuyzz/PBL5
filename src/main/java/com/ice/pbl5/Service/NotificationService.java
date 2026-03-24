package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.MarkReadResponse;
import com.ice.pbl5.DTO.Response.NotificationResponse;
import com.ice.pbl5.DTO.Response.PageResponse;
import com.ice.pbl5.DTO.Response.ReadAllResponse;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Enum.NotificationLevel;

import java.util.UUID;

public interface NotificationService {
    PageResponse<NotificationResponse> getNotification(UUID systemId,NotificationLevel level, Integer page, Integer size, String username);
    MarkReadResponse markAsRead(UUID id, UUID systemId, String username);
    ReadAllResponse markAllAsRead(UUID systemId, String username);
    long getUnreadCount(UUID systemId, String username);
    void createNotification(Detection detection, NotificationLevel level, String title, String message);
}
