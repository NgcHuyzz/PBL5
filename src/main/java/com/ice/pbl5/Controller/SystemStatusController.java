package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Request.SystemControlRequest;
import com.ice.pbl5.DTO.Response.ApiResponse;
import com.ice.pbl5.DTO.Response.DeviceStatusResponse;
import com.ice.pbl5.DTO.Response.SystemStatusResponse;
import com.ice.pbl5.Enum.SystemStatus;
import com.ice.pbl5.Service.SystemService;
import com.ice.pbl5.Service.SystemStatusService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/system")
public class SystemStatusController {
    private final SystemStatusService systemStatusService;
    private final SystemService systemService;

    public SystemStatusController(SystemStatusService systemStatusService, SystemService systemService) {
        this.systemStatusService = systemStatusService;
        this.systemService = systemService;
    }

    @GetMapping("/status")
    public ResponseEntity<ApiResponse<SystemStatusResponse>> getSystemStatus(
            @RequestParam UUID systemId,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "System status fetched successfully",
                systemStatusService.getSystemStatus(systemId, username)
        ));
    }

    @GetMapping("/devices")
    public ResponseEntity<ApiResponse<List<DeviceStatusResponse>>> getDevices(
            @RequestParam UUID systemId,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Device statuses fetched successfully",
                systemStatusService.getDeviceStatuses(systemId, username)
        ));
    }

    @PostMapping("/control")
    public ResponseEntity<ApiResponse<SystemStatus>> controlSystem(
            @RequestParam UUID systemId,
            @Valid @RequestBody SystemControlRequest request,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "System control executed successfully",
                systemService.controlSystem(systemId, request, username)
        ));
    }

    @GetMapping("/control-state")
    public ResponseEntity<ApiResponse<SystemStatus>> getControlState(
            @RequestParam UUID systemId,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Control state fetched successfully",
                systemService.getControlState(systemId, username)
        ));
    }
}
