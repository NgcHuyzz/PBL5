package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.DeviceStatusResponse;
import com.ice.pbl5.DTO.Response.SystemStatusResponse;
import com.ice.pbl5.Entity.DeviceStatus;
import com.ice.pbl5.Exception.ResourceNotFoundException;
import com.ice.pbl5.Enum.DeviceState;
import com.ice.pbl5.Enum.SystemStatus;
import com.ice.pbl5.Repository.DeviceStatusRepo;
import com.ice.pbl5.Repository.SystemRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class SystemStatusServiceImpl implements SystemStatusService{

    private final DeviceStatusRepo deviceStatusRepo;
    private final SystemRepo systemRepo;

    public SystemStatusServiceImpl(DeviceStatusRepo deviceStatusRepo, SystemRepo systemRepo) {
        this.deviceStatusRepo = deviceStatusRepo;
        this.systemRepo = systemRepo;
    }

    @Override
    public SystemStatusResponse getSystemStatus(UUID systemId, String username) {
        assertOwnedSystem(systemId, username);
        List<DeviceStatus> deviceStatuses = deviceStatusRepo.findBySystem_Id(systemId);

        Map<String, DeviceState> map = deviceStatuses.stream()
                .collect(Collectors.toMap(DeviceStatus::getDeviceName, DeviceStatus::getStatus));

        DeviceState conveyor = map.getOrDefault("Conveyor", DeviceState.ERROR);
        DeviceState camera = map.getOrDefault("Camera", DeviceState.ERROR);
        DeviceState ai;
        DeviceStatus aiWorker = deviceStatusRepo.findByDeviceName("AI Worker").orElse(null);
        if(aiWorker == null)
            ai = DeviceState.ERROR;
        else
            ai = aiWorker.getStatus();

        SystemStatus systemStatus = calculateSystemStatus(conveyor, camera, ai);

        LocalDateTime lastUpdated = deviceStatuses.stream()
                .map(DeviceStatus::getLastSeen)
                .filter(Objects::nonNull)
                .max(Comparator.naturalOrder())
                .orElse(null);

        return new SystemStatusResponse(systemStatus, conveyor, camera, ai, lastUpdated);
    }

    private SystemStatus calculateSystemStatus(DeviceState conveyor, DeviceState camera, DeviceState aiWorker) {
        if(DeviceState.ONLINE.equals(conveyor)
            && DeviceState.ONLINE.equals(camera)
            && DeviceState.ONLINE.equals(aiWorker))
        {
            return SystemStatus.RUNNING;
        }

        if(DeviceState.OFFLINE.equals(conveyor)
                && DeviceState.OFFLINE.equals(camera)
                && DeviceState.OFFLINE.equals(aiWorker))
        {
            return SystemStatus.IDLE;
        }

        if(DeviceState.OFFLINE.equals(conveyor))
        {
            return SystemStatus.STOPPED;
        }

        return SystemStatus.ERROR;
    }

    @Override
    public List<DeviceStatusResponse> getDeviceStatuses(UUID systemId, String username) {
        assertOwnedSystem(systemId, username);
        List<DeviceStatusResponse> deviceStatusResponses = new ArrayList<>(deviceStatusRepo.findBySystem_Id(systemId).stream()
                .map(d -> new DeviceStatusResponse(
                        d.getDeviceName(),
                        d.getStatus(),
                        d.getLastSeen()
                )).toList());

        DeviceStatus aiWorker = deviceStatusRepo.findByDeviceName("AI Worker").orElse(null);
        if(aiWorker == null)
            return deviceStatusResponses;

        boolean aiAlreadyIncluded = deviceStatusResponses.stream()
                .anyMatch(d -> "AI Worker".equals(d.getDeviceName()));
        if (!aiAlreadyIncluded) {
            deviceStatusResponses.add(new DeviceStatusResponse(aiWorker.getDeviceName(), aiWorker.getStatus(), aiWorker.getLastSeen()));
        }

        return deviceStatusResponses;

    }

    private void assertOwnedSystem(UUID systemId, String username) {
        systemRepo.findByIdAndUser_Username(systemId, username)
                .orElseThrow(() -> new ResourceNotFoundException("System not found"));
    }
}
