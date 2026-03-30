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
    Page<Notification> findAllBySystem_IdAndSystem_User_Username(UUID systemId, String username ,Pageable pageable);

    Page<Notification> findBySystem_IdAndSystem_User_UsernameAndLevel(UUID systemId,String username,NotificationLevel level, Pageable pageable);

    long countBySystem_IdAndSystem_User_UsernameAndIsReadFalse(UUID systemId, String username);

    Optional<Notification> findByIdAndSystem_IdAndSystem_User_Username(UUID id, UUID systemId, String username);

    List<Notification> findBySystem_IdAndSystem_User_UsernameAndIsReadFalse(UUID systemId, String username);
}
