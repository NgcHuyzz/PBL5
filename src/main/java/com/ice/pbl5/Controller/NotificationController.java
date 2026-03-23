package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Response.*;
import com.ice.pbl5.Enum.NotificationLevel;
import com.ice.pbl5.Service.NotificationService;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping()
    public ApiResponse<PageResponse<NotificationResponse>> getNotifications(
            @RequestParam(required = false) NotificationLevel level,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam UUID systemId
            )
    {
        return ApiResponse.success(
                "Notifications fetched successfully",
                notificationService.getNotification(systemId,level, page, size)
        );
    }

    @PatchMapping("/{id}/read")
    public ApiResponse<MarkReadResponse> markAsRead(@PathVariable UUID id, @RequestParam UUID systemId)
    {
        return ApiResponse.success(
                "Notification marked as read successfully",
                notificationService.markAsRead(id, systemId)
        );
    }

    @PatchMapping("/read-all")
    public ApiResponse<ReadAllResponse> markAllAsRead(@RequestParam UUID systemId) {
        return ApiResponse.success(
                "All notifications marked as read successfully",
                notificationService.markAllAsRead(systemId)
        );
    }

    @GetMapping("/unread-count")
    public ApiResponse<Long> getUnreadCount(@RequestParam UUID systemId) {
        return ApiResponse.success(
                "Unread notification count fetched successfully",
                notificationService.getUnreadCount(systemId)
        );
    }
}
