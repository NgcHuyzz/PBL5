package com.ice.pbl5.Entity;

import jakarta.persistence.*;

import java.util.UUID;

@Entity
@Table(name = "fruit_catalog")
public class FruitCatalog {
    @Id
    @Column(name = "id")
    UUID id;

    @Column(name = "name",unique = true, nullable = false)
    private String name;

    @Column(name = "vietnam_name")
    private String vietnamName;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    @PrePersist
    public void prePersist()
    {
        if(id == null)
            id = UUID.randomUUID();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getVietnamName() {
        return vietnamName;
    }

    public void setVietnamName(String vietnamName) {
        this.vietnamName = vietnamName;
    }
}
