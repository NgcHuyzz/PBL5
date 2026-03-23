package com.ice.pbl5.Repository;

import com.ice.pbl5.Entity.Notification;
import com.ice.pbl5.Enum.NotificationLevel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationRepo extends JpaRepository<Notification, UUID> {
    Page<Notification> findAllBySystem_IdOrderByCreatedAtDesc(UUID systemId ,Pageable pageable);

    Page<Notification> findBySystem_IdAndLevelOrderByCreatedAtDesc(UUID systemId,NotificationLevel level, Pageable pageable);

    long countBySystem_IdAndIsReadFalse(UUID systemId);

    Optional<Notification> findByIdAndSystem_Id(UUID id, UUID systemId);

    List<Notification> findBySystem_IdAndIsReadFalse(UUID systemId);
}
