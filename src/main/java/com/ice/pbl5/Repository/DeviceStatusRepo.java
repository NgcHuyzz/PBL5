package com.ice.pbl5.Repository;

import com.ice.pbl5.Entity.DeviceStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeviceStatusRepo extends JpaRepository<DeviceStatus, Long> {
    Optional<DeviceStatus> findByDeviceName(String deviceName);
    List<DeviceStatus> findBySystem_Id(UUID systemId);
}
