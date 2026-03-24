package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.AiTCPResponse;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Enum.DetectionStatus;
import com.ice.pbl5.Exception.ResourceNotFoundException;
import com.ice.pbl5.Repository.DetectionRepo;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class DetectionAsyncService {

    private final DetectionRepo detectionRepo;
    private final AiTCPClientService aiTCPClientService;

    public DetectionAsyncService(DetectionRepo detectionRepo, AiTCPClientService aiTCPClientService) {
        this.detectionRepo = detectionRepo;
        this.aiTCPClientService = aiTCPClientService;
    }

    @Transactional
    public void processDetection(UUID detectionId) {
        Detection detection = detectionRepo.findById(detectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Detection not found"));
        LocalDateTime startTime = LocalDateTime.now();
        try
        {
            detection.setStatus(DetectionStatus.PROCESSING);
            detectionRepo.save(detection);

            byte[] imgBytes = Files.readAllBytes(Path.of(detection.getImageUrl()));
            AiTCPResponse aiTCPResponse = aiTCPClientService.classify(imgBytes);

            int processingTime = (int) Duration.between(startTime, LocalDateTime.now()).toMillis();
            detection.setAiProcessingTimeMs(processingTime);

            if (!aiTCPResponse.isSuccess()) {
                detection.setStatus(DetectionStatus.FAILED);
                detection.setErrorMessage(aiTCPResponse.getMessage());
                detection.setCompletedAt(LocalDateTime.now());
            }

            detection.setFruitType(aiTCPResponse.getFruitType());
            detection.setConfidence(BigDecimal.valueOf(aiTCPResponse.getConfidence()));
            detection.setClassifiedAt(LocalDateTime.now());
            detection.setTargetBin(mapTargetBin(detection.getFruitType(), aiTCPResponse.getConfidence()));
            // thực hiện gửi xuống vi điều khiển


            // sau khi gửi thành công
            detection.setStatus(DetectionStatus.COMPLETED);
            detection.setCompletedAt(LocalDateTime.now());
        }
        catch (Exception e) {
            detection.setStatus(DetectionStatus.FAILED);
            detection.setErrorMessage(e.getMessage());
            detection.setCompletedAt(LocalDateTime.now());
        }

    }

    private String mapTargetBin(String fruitType, Double confidence)
    {
        if (confidence == null || confidence < 0.7) {
            return "REJECT_BIN";
        }

        return switch (fruitType.toUpperCase())
        {
            case ".." -> "BIN_1";
            case "..." -> "BIN_2";
            case "...." -> "BIN_3";
            default -> "REJECT_BIN";
        };
    }
}
