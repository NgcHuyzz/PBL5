package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.*;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Enum.DetectionStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface DetectionService {
    DetectionResponse getLatestDetection(UUID systemId, String username);
    List<DetectionResponse> getRecentDetections(UUID systemId, Integer limit, String username);
    List<FruitCountResponse> countByFruit(UUID systemId, LocalDateTime from, LocalDateTime to, String username);
    SummaryStatisticsResponse getSummary(UUID systemId, LocalDateTime from, LocalDateTime to, String username);
    List<DailyStatisticsResponse> getDaily(UUID systemId, LocalDateTime from, LocalDateTime to, String username);
    PageResponse<DetectionDetailResponse> getDetectionHistory(UUID systemId, Integer page, Integer size, String fruitType, DetectionStatus status, LocalDateTime from, LocalDateTime to, String username);
    DetectionDetailResponse getDetectionDetail(UUID id, UUID systemId, String username);
    public Detection createDetection(UUID systemId, String deviceId, String imagePath);
}
