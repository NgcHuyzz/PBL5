package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.*;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Enum.DetectionStatus;
import com.ice.pbl5.Exception.ResourceNotFoundException;
import com.ice.pbl5.Repository.DetectionRepo;
import com.ice.pbl5.Repository.SystemRepo;
import com.ice.pbl5.Util.DetectionSpecification;
import jakarta.transaction.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Service
public class DetectionServiceImpl implements DetectionService{

    private final DetectionRepo detectionRepo;
    private final ImgUrlService imgUrlService;
    private final SystemAccessService systemAccessService;
    private final SystemRepo systemRepo;
    private final DetectionAsyncService detectionAsyncService;

    public DetectionServiceImpl(DetectionRepo detectionRepo, ImgUrlService imgUrlService, SystemAccessService systemAccessService, SystemRepo systemRepo, DetectionAsyncService detectionAsyncService) {
        this.detectionRepo = detectionRepo;
        this.imgUrlService = imgUrlService;
        this.systemAccessService = systemAccessService;
        this.systemRepo = systemRepo;
        this.detectionAsyncService = detectionAsyncService;
    }

    @Override
    public DetectionResponse getLatestDetection(UUID systemId, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        Detection detection = detectionRepo.findTopBySystem_IdAndSystem_User_UsernameOrderByCreatedAtDesc(system.getId(), username)
                .orElseThrow(() -> new ResourceNotFoundException("No detection found for systemId: " + systemId));

        return new DetectionResponse(
                detection.getId(),
                detection.getFruitType(),
                detection.getConfidence(),
                detection.getTargetBin(),
                detection.getClassifiedAt(),
                imgUrlService.buildImgUrl(detection.getImageUrl())
        );

    }

    @Override
    public List<DetectionResponse> getRecentDetections(UUID systemId, Integer limit, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        int actualLimit = (limit == null || limit <= 0) ? 10 : limit;

        return detectionRepo.findBySystem_IdAndSystem_User_UsernameOrderByCreatedAtDesc(system.getId(), username, PageRequest.of(0, actualLimit)).stream()
                .map(d -> new DetectionResponse(
                        d.getId(),
                        d.getFruitType(),
                        d.getConfidence(),
                        d.getTargetBin(),
                        d.getClassifiedAt(),
                        imgUrlService.buildImgUrl(d.getImageUrl())
                )).toList();
    }

    @Override
    public List<FruitCountResponse> countByFruit(UUID systemId, LocalDateTime from, LocalDateTime to, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        if ((from == null) != (to == null)) {
            throw new IllegalArgumentException("Both 'from' and 'to' must be provided together");
        }

        LocalDateTime actualFrom;
        LocalDateTime actualTo;

        if (from == null) {
            LocalDate today = LocalDate.now();
            actualFrom = today.atStartOfDay();
            actualTo = today.atTime(LocalTime.MAX);
        } else {
            actualFrom = from;
            actualTo = to;
        }

        if (actualFrom.isAfter(actualTo)) {
            throw new IllegalArgumentException("'from' must be before or equal to 'to'");
        }

        return detectionRepo.countByFruitTypeBetweenAndSystemId(system.getId(), username,actualFrom, actualTo);

    }

    @Override
    public SummaryStatisticsResponse getSummary(UUID systemId, LocalDateTime from, LocalDateTime to, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        if ((from == null) != (to == null)) {
            throw new IllegalArgumentException("Both 'from' and 'to' must be provided together");
        }

        LocalDateTime actualFrom;
        LocalDateTime actualTo;

        if(from == null)
        {
            LocalDate today = LocalDate.now();
            actualFrom = today.atStartOfDay();
            actualTo = today.atTime(LocalTime.MAX);
        }
        else
        {
            actualFrom = from;
            actualTo = to;
        }

        if (actualFrom.isAfter(actualTo)) {
            throw new IllegalArgumentException("'from' must be before or equal to 'to'");
        }

        long totalProcessing = detectionRepo.countByStatusAndCreatedAtBetweenAndSystemId(system.getId(), username,DetectionStatus.PROCESSING, actualFrom, actualTo);

        long totalCompleted = detectionRepo.countByStatusAndCreatedAtBetweenAndSystemId(system.getId(), username,DetectionStatus.COMPLETED, actualFrom, actualTo);

        long totalFailed = detectionRepo.countByStatusAndCreatedAtBetweenAndSystemId(system.getId(), username, DetectionStatus.FAILED, actualFrom, actualTo);

        long totalRecived = totalProcessing + totalCompleted + totalFailed;

        Double averageProcessingTimeMs = detectionRepo.averageProcessingTimeBetween(system.getId(), username, actualFrom, actualTo);
        if (averageProcessingTimeMs == null) {
            averageProcessingTimeMs = 0.0;
        }

        return new SummaryStatisticsResponse(totalRecived, totalProcessing, totalCompleted, totalFailed, averageProcessingTimeMs);
    }

    @Override
    public List<DailyStatisticsResponse> getDaily(UUID systemId, LocalDateTime from, LocalDateTime to, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        if ((from == null) != (to == null)) {
            throw new IllegalArgumentException("Both 'from' and 'to' must be provided together");
        }

        LocalDateTime actualFrom;
        LocalDateTime actualTo;

        if(from == null)
        {
            LocalDate today = LocalDate.now();
            actualFrom = today.atStartOfDay();
            actualTo = today.atTime(LocalTime.MAX);
        }
        else
        {
            actualFrom = from;
            actualTo = to;
        }

        if (actualFrom.isAfter(actualTo)) {
            throw new IllegalArgumentException("'from' must be before or equal to 'to'");
        }

        return detectionRepo.countDailyBetween(system.getId(), username, actualFrom, actualTo);
    }

    @Override
    public PageResponse<DetectionDetailResponse> getDetectionHistory(UUID systemId, Integer page, Integer size, String fruitType, DetectionStatus status, LocalDateTime from, LocalDateTime to, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        int actualPage = Math.max(page, 0);
        int actualSize = (size <= 0) ? 10 : size;

        Specification<Detection> spec = Specification
                .where(DetectionSpecification.hasSystemId(system.getId()))
                .and(DetectionSpecification.hasOwnerUsername(username))
                .and(DetectionSpecification.hasFruitType(fruitType))
                .and(DetectionSpecification.hasStatus(status))
                .and(DetectionSpecification.createdFrom(from))
                .and(DetectionSpecification.createdTo(to));

        Page<Detection> detectionPage = detectionRepo.findAll(spec, PageRequest.of(actualPage, actualSize, Sort.by(Sort.Direction.DESC, "createdAt")));

        List<DetectionDetailResponse> content = detectionPage.getContent().stream()
                .map(detection -> new DetectionDetailResponse(
                        detection.getId(),
                        detection.getDeviceId(),
                        imgUrlService.buildImgUrl(detection.getImageUrl()),
                        detection.getFruitType(),
                        detection.getConfidence(),
                        detection.getTargetBin(),
                        detection.getStatus(),
                        detection.getAiProcessingTimeMs(),
                        detection.getCreatedAt(),
                        detection.getClassifiedAt(),
                        detection.getCompletedAt()
                )).toList();

        return new PageResponse<DetectionDetailResponse>(
                content,
                detectionPage.getNumber(),
                detectionPage.getSize(),
                detectionPage.getTotalElements(),
                detectionPage.getTotalPages()
        );
    }

    @Override
    public DetectionDetailResponse getDetectionDetail(UUID id, UUID systemId, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);
        Detection detection = detectionRepo.findByIdAndSystem_IdAndSystem_User_Username(id, system.getId(), username)
                .orElseThrow(() -> new ResourceNotFoundException("No detection found for id: " + id + " and systemId: " + systemId));
        return new DetectionDetailResponse(
                detection.getId(),
                detection.getDeviceId(),
                imgUrlService.buildImgUrl(detection.getImageUrl()),
                detection.getFruitType(),
                detection.getConfidence(),
                detection.getTargetBin(),
                detection.getStatus(),
                detection.getAiProcessingTimeMs(),
                detection.getCreatedAt(),
                detection.getClassifiedAt(),
                detection.getCompletedAt()
        );
    }

    @Override
    @Transactional
    public Detection createDetection(UUID systemId, String deviceId, String imagePath) {
        System system = systemRepo.findById(systemId)
                .orElseThrow(() -> new ResourceNotFoundException("System not found"));

        Detection detection = new Detection();
        detection.setSystem(system);
        detection.setDeviceId(deviceId);
        detection.setImageUrl(imagePath);

        detection.setStatus(DetectionStatus.RECEIVED);
        detection.setCreatedAt(LocalDateTime.now());

        Detection detectionSave = detectionRepo.save(detection);

        detectionAsyncService.processDetection(detection.getId());

        return detectionSave;
    }

}
