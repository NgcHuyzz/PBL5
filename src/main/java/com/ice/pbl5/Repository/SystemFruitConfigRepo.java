package com.ice.pbl5.Repository;

import com.ice.pbl5.Entity.SystemFruitConfig;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface SystemFruitConfigRepo extends JpaRepository<SystemFruitConfig, UUID> {
    List<SystemFruitConfig> findBySystem_IdAndSystem_User_Username(UUID systemId, String username);

    void deleteBySystem_IdAndSystem_User_Username(UUID systemId, String username);
}
