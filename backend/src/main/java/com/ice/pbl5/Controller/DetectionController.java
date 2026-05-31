package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Response.*;
import com.ice.pbl5.Enum.DetectionStatus;
import com.ice.pbl5.Service.DetectionService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@Validated
@RequestMapping("/api/detections")
public class DetectionController {
    private final DetectionService detectionService;

    public DetectionController(DetectionService detectionService) {
        this.detectionService = detectionService;
    }

    @GetMapping("/latest")
    public ResponseEntity<ApiResponse<DetectionResponse>> getLatestDetection(@RequestParam UUID systemId, Authentication authentication)
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Latest detection fetched successfully",
                detectionService.getLatestDetection(systemId, username)
        ));
    }

    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<List<DetectionResponse>>> getRecentDetection(
            @RequestParam UUID systemId,
            @RequestParam(defaultValue = "10")
            @Min(value = 1, message = "limit must be >= 1")
            @Max(value = 100, message = "limit must be <= 100")
            Integer limit,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
            "Recent detections fetched successfully",
            detectionService.getRecentDetections(systemId, limit, username)
        ));
    }

    @GetMapping("/count-by-fruit")
    public ResponseEntity<ApiResponse<List<FruitCountResponse>>> countByFruit(
            @RequestParam UUID systemId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime to,
            Authentication authentication
            )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
            "Fruit counts fetched successfully",
                detectionService.countByFruit(systemId, from, to,username)
        ));
    }

    @GetMapping("/statistics-summary")
    public ResponseEntity<ApiResponse<SummaryStatisticsResponse>> getSummary(
            @RequestParam UUID systemId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime to,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Summary statistics fetched successfully",
                detectionService.getSummary(systemId, from, to, username)
        ));
    }

    @GetMapping("/statistics-daily")
    public ResponseEntity<ApiResponse<List<DailyStatisticsResponse>>> getDaily(
            @RequestParam UUID systemId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime to,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Daily statistics fetched successfully",
                detectionService.getDaily(systemId, from, to, username)
        ));
    }

    @GetMapping()
    public ResponseEntity<ApiResponse<PageResponse<DetectionDetailResponse>>> getHistory(
            @RequestParam UUID systemId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String fruitType,
            @RequestParam(required = false) DetectionStatus status,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime to,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Detection history fetched successfully",
                detectionService.getDetectionHistory(systemId,page, size, fruitType, status, from, to, username)
        ));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<DetectionDetailResponse>> getDetail(
            @PathVariable UUID id,
            @RequestParam UUID systemId,
            Authentication authentication
    )
    {
        String username = authentication.getName();
        return ResponseEntity.ok(ApiResponse.success(
                "Detection detail fetched successfully",
                detectionService.getDetectionDetail(id, systemId, username)
        ));
    }
}
