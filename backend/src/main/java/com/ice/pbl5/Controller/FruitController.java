package com.ice.pbl5.Controller;

import com.ice.pbl5.DTO.Request.FruitConfigItemRequest;
import com.ice.pbl5.DTO.Response.ApiResponse;
import com.ice.pbl5.DTO.Response.FruitCatalogResponse;
import com.ice.pbl5.DTO.Response.FruitConfigResponse;
import com.ice.pbl5.Service.FruitService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/fruits")
public class FruitController {

    private final FruitService fruitService;

    public FruitController(FruitService fruitService) {
        this.fruitService = fruitService;
    }

    @GetMapping("/catalog")
    public ResponseEntity<ApiResponse<List<FruitCatalogResponse>>> getCatalog() {
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Fruit catalog fetched successfully",
                        fruitService.getCatalog()
                )
        );
    }

    // API 7
    @GetMapping("/fruit-config")
    public ResponseEntity<ApiResponse<List<FruitConfigResponse>>> getConfig(
            @RequestParam UUID systemId,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(
                ApiResponse.success(
                        "System fruit config fetched successfull",
                        fruitService.getConfig(systemId, username)
                )
        );
    }

    // API 8
    @PutMapping("/fruit-config")
    public ResponseEntity<ApiResponse<List<FruitConfigResponse>>> updateConfig(
            @RequestParam UUID systemId,
            @RequestBody List<FruitConfigItemRequest> request,
            Authentication authentication
    ) {
        String username = authentication.getName();
        return ResponseEntity.ok(
                ApiResponse.success(
                        "System fruit config updated successfully",
                        fruitService.updateConfig(systemId, request, username)
                )
        );
    }


}
