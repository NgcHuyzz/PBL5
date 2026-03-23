package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.*;
import com.ice.pbl5.Enum.DetectionStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface DetectionService {
    DetectionResponse getLatestDetection(UUID systemId);
    List<DetectionResponse> getRecentDetections(UUID systemId, Integer limit);
    List<FruitCountResponse> countByFruit(UUID systemId, LocalDateTime from, LocalDateTime to);
    SummaryStatisticsResponse getSummary(UUID systemId, LocalDateTime from, LocalDateTime to);
    List<DailyStatisticsResponse> getDaily(UUID systemId, LocalDateTime from, LocalDateTime to);
    PageResponse<DetectionDetailResponse> getDetectionHistory(UUID systemId, Integer page, Integer size, String fruitType, DetectionStatus status, LocalDateTime from, LocalDateTime to);
    DetectionDetailResponse getDetectionDetail(UUID id, UUID systemId);
}
