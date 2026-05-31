package com.ice.pbl5.Repository;

import com.ice.pbl5.Entity.FruitCatalog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface FruitCatalogRepo extends JpaRepository<FruitCatalog, UUID> {
}
