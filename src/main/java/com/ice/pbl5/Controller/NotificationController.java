package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Response.*;
import com.ice.pbl5.Enum.NotificationLevel;
import com.ice.pbl5.Service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
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
    public ResponseEntity<ApiResponse<PageResponse<NotificationResponse>>> getNotifications(
            @RequestParam(required = false) NotificationLevel level,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam UUID systemId,
            Authentication authentication
            )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Notifications fetched successfully",
                notificationService.getNotification(systemId,level, page, size, username)
        ));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<ApiResponse<MarkReadResponse>> markAsRead(@PathVariable UUID id, @RequestParam UUID systemId, Authentication authentication)
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Notification marked as read successfully",
                notificationService.markAsRead(id, systemId, username)
        ));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<ApiResponse<ReadAllResponse>> markAllAsRead(@RequestParam UUID systemId, Authentication authentication) {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "All notifications marked as read successfully",
                notificationService.markAllAsRead(systemId,username)
        ));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@RequestParam UUID systemId, Authentication authentication) {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Unread notification count fetched successfully",
                notificationService.getUnreadCount(systemId,username)
        ));
    }
}
