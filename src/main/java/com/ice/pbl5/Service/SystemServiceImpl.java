package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.SystemControlRequest;
import com.ice.pbl5.DTO.Response.DeviceCommandResponse;
import com.ice.pbl5.DTO.Response.SystemResponse;
import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Entity.User;
import com.ice.pbl5.Enum.*;
import com.ice.pbl5.Exception.ResourceNotFoundException;
import com.ice.pbl5.Repository.SystemRepo;
import com.ice.pbl5.Repository.UserRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class SystemServiceImpl implements SystemService {

    private final SystemRepo systemRepo;
    private final UserRepo userRepo;
    private final SystemAccessService systemAccessService;
    private final CommandService commandService;

    public SystemServiceImpl(SystemRepo systemRepo, UserRepo userRepo, SystemAccessService systemAccessService, CommandService commandService) {
        this.systemRepo = systemRepo;
        this.userRepo = userRepo;
        this.systemAccessService = systemAccessService;
        this.commandService = commandService;
    }

    @Override
    public List<SystemResponse> getMySystems(String username) {
        User user = userRepo.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return systemRepo.findAllByUser_IdOrderByCreatedAtDesc(user.getId()).stream()
                .map(system -> new SystemResponse(
                        system.getId(),
                        system.getSystemName(),
                        system.getDescription(),
                        system.getLocation(),
                        system.getStatus(),
                        system.getCreatedAt(),
                        system.getUpdatedAt()
                )).toList();
    }

    @Override
    public SystemStatus controlSystem(UUID systemId, SystemControlRequest request, String username) {
        System system = systemAccessService.getOwnedSystem(systemId, username);

        SystemAction action = request.getAction();
        CommandType type;
        SystemStatus targetStatus;
        switch (action) {
            case START -> {
                if (system.getStatus() == SystemStatus.RUNNING) {
                    throw new IllegalArgumentException("System is already running");
                }
                targetStatus = SystemStatus.RUNNING;
                type = CommandType.START_CONVEYOR;
            }
            case PAUSE -> {
                if (system.getStatus() == SystemStatus.STOPPED) {
                    throw new IllegalArgumentException("Cannot pause a stopped system");
                }
                if (system.getStatus() == SystemStatus.PAUSED) {
                    throw new IllegalArgumentException("System is already paused");
                }
                targetStatus = SystemStatus.PAUSED;
                type = CommandType.PAUSE_CONVEYOR;
            }
            case STOP -> {
                if (system.getStatus() == SystemStatus.STOPPED) {
                    throw new IllegalArgumentException("System is already stopped");
                }
                targetStatus = SystemStatus.STOPPED;
                type = CommandType.STOP_CONVEYOR;
            }
            default -> throw new IllegalStateException("Unexpected value: " + action);
        }

        DeviceCommandResponse response = commandService.executeControlCommand(system, type);
        if (!response.isSuccess()) {
            throw new IllegalArgumentException("Cannot control system: " + response.getMessage());
        }

        system.setStatus(targetStatus);
        system.setUpdatedAt(LocalDateTime.now());
        systemRepo.save(system);
        return system.getStatus();
    }

    @Override
    public SystemStatus getControlState(UUID systemId, String username) {
        return systemAccessService.getOwnedSystem(systemId, username).getStatus();
    }

    @Override
    public UUID register(String name, String description, String location) {
        System system = new System();
        system.setSystemName(name);
        system.setDescription(description);
        system.setStatus(SystemStatus.IDLE);
        system.setCreatedAt(LocalDateTime.now());
        system.setUpdatedAt(LocalDateTime.now());

        System s = systemRepo.save(system);

        return s.getId();
    }


}
