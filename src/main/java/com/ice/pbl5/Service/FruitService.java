package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.FruitConfigItemRequest;
import com.ice.pbl5.DTO.Response.FruitCatalogResponse;
import com.ice.pbl5.DTO.Response.FruitConfigResponse;

import java.util.List;
import java.util.UUID;

public interface FruitService {
    List<FruitCatalogResponse> getCatalog();
    List<FruitConfigResponse> getConfig(UUID systemId, String username);
    List<FruitConfigResponse> updateConfig(UUID systemId, List<FruitConfigItemRequest> request, String username);
}
