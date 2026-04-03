package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.AiTCPResponse;
import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Enum.DetectionStatus;
import com.ice.pbl5.Enum.NotificationLevel;
import com.ice.pbl5.Exception.ResourceNotFoundException;
import com.ice.pbl5.Repository.DetectionRepo;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class DetectionAsyncService {
    private static final BigDecimal CONFIDENCE_THRESHOLD = new BigDecimal("0.7");

    private final DetectionRepo detectionRepo;
    private final AiTCPClientService aiTCPClientService;
    private final CommandService commandService;
    private final NotificationService notificationService;

    public DetectionAsyncService(
            DetectionRepo detectionRepo,
            AiTCPClientService aiTCPClientService,
            CommandService commandService,
            NotificationService notificationService
    ) {
        this.detectionRepo = detectionRepo;
        this.aiTCPClientService = aiTCPClientService;
        this.commandService = commandService;
        this.notificationService = notificationService;
    }

    @Async("ai-worker")
    public void processDetection(UUID detectionId, String requestId) {
        Detection detection = detectionRepo.findById(detectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Detection not found"));
        LocalDateTime startTime = LocalDateTime.now();
        try {
            detection.setStatus(DetectionStatus.PROCESSING);
            detectionRepo.save(detection);

            byte[] imgBytes = Files.readAllBytes(Path.of(detection.getImageUrl()));
            AiTCPResponse aiTCPResponse = aiTCPClientService.classify(imgBytes);

            int processingTime = (int) Duration.between(startTime, LocalDateTime.now()).toMillis();
            detection.setAiProcessingTimeMs(processingTime);

            if (!aiTCPResponse.isSuccess()) {
                detection.setFruitType("UNKNOWN");
                detection.setConfidence(BigDecimal.ZERO);
                detection.setTargetBin("REJECT_BIN");
                detection.setClassifiedAt(LocalDateTime.now());
                detection.setErrorMessage(aiTCPResponse.getMessage());

                DeviceCommandResponse fallbackResponse = commandService.executeSortCommand(detection, requestId);
                if (!fallbackResponse.isSuccess()) {
                    detection.setStatus(DetectionStatus.FAILED);
                    detection.setCompletedAt(LocalDateTime.now());
                    detection.setErrorMessage("AI failed and cannot send fallback result: " + fallbackResponse.getMessage());
                    detectionRepo.save(detection);

                    notificationService.createNotification(
                            detection,
                            NotificationLevel.ERROR,
                            "AI classification failed",
                            aiTCPResponse.getMessage()
                    );
                    return;
                }

                detection.setStatus(DetectionStatus.COMPLETED);
                detection.setCompletedAt(LocalDateTime.now());
                detectionRepo.save(detection);

                notificationService.createNotification(
                        detection,
                        NotificationLevel.ERROR,
                        "AI classification failed",
                        aiTCPResponse.getMessage()
                );
                return;
            }

            BigDecimal confidence = aiTCPResponse.getConfidence();
            detection.setFruitType(aiTCPResponse.getFruitType());
            detection.setClassifiedAt(LocalDateTime.now());
            detection.setTargetBin(mapTargetBin(detection.getFruitType(), confidence));
            detection.setConfidence(confidence == null ? BigDecimal.ZERO : confidence);

            if (confidence == null || confidence.compareTo(CONFIDENCE_THRESHOLD) < 0) {
                notificationService.createNotification(
                        detection,
                        NotificationLevel.WARNING,
                        "Low confidence detection",
                        "Fruit classified with low confidence: " + confidence
                );
            }

            DeviceCommandResponse response = commandService.executeSortCommand(detection, requestId);
            if (!response.isSuccess()) {
                detection.setStatus(DetectionStatus.FAILED);
                detection.setCompletedAt(LocalDateTime.now());
                detection.setErrorMessage(response.getMessage());
                detectionRepo.save(detection);

                notificationService.createNotification(
                        detection,
                        NotificationLevel.ERROR,
                        "Device command failed",
                        response.getMessage()
                );
                return;
            }

            detection.setStatus(DetectionStatus.COMPLETED);
            detection.setCompletedAt(LocalDateTime.now());
            detectionRepo.save(detection);
        } catch (Exception e) {
            detection.setStatus(DetectionStatus.FAILED);
            detection.setErrorMessage(e.getMessage());
            detection.setCompletedAt(LocalDateTime.now());
            detectionRepo.save(detection);
        }
    }

    private String mapTargetBin(String fruitType, BigDecimal confidence) {
        if (confidence == null || confidence.compareTo(CONFIDENCE_THRESHOLD) < 0) {
            return "REJECT_BIN";
        }
        if (fruitType == null || fruitType.isBlank()) {
            return "REJECT_BIN";
        }

        return switch (fruitType.toUpperCase()) {
            case ".." -> "BIN_1";
            case "..." -> "BIN_2";
            case "...." -> "BIN_3";
            default -> "REJECT_BIN";
        };
    }
}
