package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.MarkReadResponse;
import com.ice.pbl5.DTO.Response.NotificationResponse;
import com.ice.pbl5.DTO.Response.PageResponse;
import com.ice.pbl5.DTO.Response.ReadAllResponse;
import com.ice.pbl5.Enum.NotificationLevel;

import java.util.UUID;

public interface NotificationService {
    PageResponse<NotificationResponse> getNotification(UUID systemId,NotificationLevel level, Integer page, Integer size);
    MarkReadResponse markAsRead(UUID id, UUID systemId);
    ReadAllResponse markAllAsRead(UUID systemId);
    long getUnreadCount(UUID systemId);
}
