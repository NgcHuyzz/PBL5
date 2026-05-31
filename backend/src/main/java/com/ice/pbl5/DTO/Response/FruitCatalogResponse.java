package com.ice.pbl5.DTO.Response;

public class FruitCatalogResponse {
    private String name;
    private String vietnamName;

    public FruitCatalogResponse() {
    }

    public FruitCatalogResponse(String name, String vietnamName) {
        this.name = name;
        this.vietnamName = vietnamName;
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
