package com.ice.pbl5.Repository;

import com.ice.pbl5.Entity.System;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SystemRepo extends JpaRepository<System, UUID> {
    List<System> findAllByUser_IdOrderByCreatedAtDesc(long userId);
    Optional<System> findByIdAndUser_Username(UUID id, String username);
}
