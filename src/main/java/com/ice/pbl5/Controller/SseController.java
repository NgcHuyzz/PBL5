package com.ice.pbl5.Controller;

import com.ice.pbl5.Service.SSEService;
import com.ice.pbl5.Service.SystemAccessService;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

@RestController
@RequestMapping("/api/sse")
public class SseController {

    private final SSEService sseService;
    private final SystemAccessService systemAccessService;

    public SseController(SSEService sseService, SystemAccessService systemAccessService) {
        this.sseService = sseService;
        this.systemAccessService = systemAccessService;
    }

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(@RequestParam UUID systemId,
                             @AuthenticationPrincipal UserDetails userDetails) {
        systemAccessService.getOwnedSystem(systemId, userDetails.getUsername());
        return sseService.register(systemId);
    }
}