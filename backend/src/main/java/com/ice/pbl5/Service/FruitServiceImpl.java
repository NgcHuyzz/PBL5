package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.FruitConfigItemRequest;
import com.ice.pbl5.DTO.Response.FruitCatalogResponse;
import com.ice.pbl5.DTO.Response.FruitConfigResponse;
import com.ice.pbl5.Entity.FruitCatalog;
import com.ice.pbl5.Entity.System;
import com.ice.pbl5.Entity.SystemFruitConfig;
import com.ice.pbl5.Repository.FruitCatalogRepo;
import com.ice.pbl5.Repository.SystemFruitConfigRepo;
import com.ice.pbl5.Repository.SystemRepo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class FruitServiceImpl implements FruitService {

    private final FruitCatalogRepo fruitCatalogRepo;
    private final SystemFruitConfigRepo systemFruitConfigRepo;
    private final SystemRepo systemRepo;

    public FruitServiceImpl(FruitCatalogRepo fruitCatalogRepo, SystemFruitConfigRepo systemFruitConfigRepo, SystemRepo systemRepo) {
        this.fruitCatalogRepo = fruitCatalogRepo;
        this.systemFruitConfigRepo = systemFruitConfigRepo;
        this.systemRepo = systemRepo;
    }

    @Override
    public List<FruitCatalogResponse> getCatalog() {
        List<FruitCatalog> fruitCatalogs = fruitCatalogRepo.findAll();

        return fruitCatalogs.stream().map(
                fruitCatalog -> new FruitCatalogResponse(
                        fruitCatalog.getName(),
                        fruitCatalog.getVietnamName()
                )
        ).toList();
    }

    @Override
    public List<FruitConfigResponse> getConfig(UUID systemId, String username) {
        List<SystemFruitConfig> systemFruitConfigs = systemFruitConfigRepo.findBySystem_IdAndSystem_User_Username(systemId, username);

        return systemFruitConfigs.stream().map(
                systemFruitConfig -> new FruitConfigResponse(
                        systemFruitConfig.getFruitName(),
                        systemFruitConfig.getTargetBin()
                )
        ).toList();
    }

    @Override
    @Transactional
    public List<FruitConfigResponse> updateConfig(UUID systemId, List<FruitConfigItemRequest> request, String username) {
        if (request == null || request.size() != 4) {
            throw new IllegalArgumentException("Must provide exactly 4 items");
        }


        System system = systemRepo.findByIdAndUser_Username(systemId, username)
                .orElseThrow(() -> new IllegalArgumentException("System ID not found"));

        systemFruitConfigRepo.deleteBySystem_IdAndSystem_User_Username(systemId, username);

        List<SystemFruitConfig> configs = request.stream().map(
                fruitConfigItemRequest -> {
                    SystemFruitConfig c = new SystemFruitConfig();
                    c.setSystem(system);
                    c.setFruitName(fruitConfigItemRequest.getFruitName());
                    c.setTargetBin(fruitConfigItemRequest.getTargetBin());
                    c.setUpdatedAt(LocalDateTime.now());
                    return c;
                }
        ).toList();

        systemFruitConfigRepo.saveAll(configs);

        return configs.stream().map(
                systemFruitConfig -> new FruitConfigResponse(
                        systemFruitConfig.getFruitName(),
                        systemFruitConfig.getTargetBin()
                )
        ).toList();
    }
}
