package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Response.ApiResponse;
import com.ice.pbl5.DTO.Response.SystemResponse;
import com.ice.pbl5.Service.SystemService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/systems")
public class SystemController {

    private final SystemService systemService;

    public SystemController(SystemService systemService) {
        this.systemService = systemService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<SystemResponse>>> getMySystems(Authentication authentication)
    {
        String username = authentication.getName();

        return ResponseEntity.ok(ApiResponse.success(
                "Systems fetched successfully",
                systemService.getMySystems(username)
        ));
    }
}
