package com.ice.pbl5.Service;

import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Exception.ResourceNotFoundException;
import com.ice.pbl5.Repository.SystemRepo;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class SystemAccessServiceImpl implements SystemAccessService{

    private final SystemRepo systemRepo;

    public SystemAccessServiceImpl(SystemRepo systemRepo) {
        this.systemRepo = systemRepo;
    }

    @Override
    public System getOwnedSystem(UUID systemId, String username) {
        return systemRepo.findByIdAndUser_Username(systemId, username)
                .orElseThrow(() -> new ResourceNotFoundException("You do not have access to this system"));
    }
}
