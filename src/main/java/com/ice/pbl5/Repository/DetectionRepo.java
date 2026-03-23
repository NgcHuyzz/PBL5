package com.ice.pbl5.Repository;

import com.ice.pbl5.DTO.Response.DailyStatisticsResponse;
import com.ice.pbl5.DTO.Response.FruitCountResponse;
import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Enum.DetectionStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DetectionRepo extends JpaRepository<Detection, UUID>, JpaSpecificationExecutor<Detection> {
    Optional<Detection> findTopBySystem_IdOrderByCreatedAtDesc(UUID systemId);
    Optional<Detection> findByIdAndSystem_Id(UUID id, UUID systemId);

    List<Detection> findBySystem_IdOrderByCreatedAtDesc(UUID systemId, Pageable pageable);

    @Query("""
        SELECT new com.ice.pbl5.DTO.Response.FruitCountResponse(d.fruitType, count(d))
        FROM Detection d
        WHERE d.createdAt >= :from
        AND d.createdAt <= :to
        GROUP BY d.fruitType
        ORDER BY COUNT(d) DESC
""")
    List<FruitCountResponse> countByFruitTypeBetween(
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );

    @Query("""
        SELECT new com.ice.pbl5.DTO.Response.FruitCountResponse(d.fruitType, count(d))
        FROM Detection d
        WHERE d.system.id = :systemId
        AND d.createdAt >= :from
        AND d.createdAt <= :to
        GROUP BY d.fruitType
        ORDER BY COUNT(d) DESC
""")
    List<FruitCountResponse> countByFruitTypeBetweenAndSystemId(
            @Param("systemId") UUID systemId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );

    @Query("""
        SELECT count(d)
        FROM Detection d
        WHERE d.system.id = :systemId
        AND d.createdAt >= :from
        AND d.createdAt <= :to
        AND d.status = :status
"""
    )
    long countByStatusAndCreatedAtBetweenAndSystemId(
            @Param("systemId") UUID systemId,
            @Param("status") DetectionStatus status,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );

    @Query("""
        SELECT avg(d.aiProcessingTimeMs)
        FROM Detection d
        WHERE d.system.id = :systemId
        AND d.createdAt >= :from
        AND d.createdAt <= :to
        AND d.status = com.ice.pbl5.Enum.DetectionStatus.COMPLETED
        AND d.aiProcessingTimeMs is not null
"""
    )
    Double averageProcessingTimeBetween(
            @Param("systemId") UUID systemId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );

    @Query("""
        SELECT new com.ice.pbl5.DTO.Response.DailyStatisticsResponse(
            function('DATE', d.createdAt),
            count(d)
        )
        FROM Detection d
        WHERE d.system.id = :systemId
        AND d.createdAt >= :from
        AND d.createdAt <= :to
        AND d.status = com.ice.pbl5.Enum.DetectionStatus.COMPLETED
        GROUP BY function('DATE', d.createdAt)
        ORDER BY function('DATE', d.createdAt)
"""
    )
    List<DailyStatisticsResponse> countDailyBetween(
            @Param("systemId") UUID systemId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );

}
