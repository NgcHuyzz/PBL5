package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Request.SystemControlRequest;
import com.ice.pbl5.DTO.Response.ApiResponse;
import com.ice.pbl5.Enum.SystemStatus;
import com.ice.pbl5.Service.SystemService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/system")
public class SystemStatusController {
    private final SystemService systemService;

    public SystemStatusController(SystemService systemService) {
        this.systemService = systemService;
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
