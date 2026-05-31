package com.ice.pbl5.DTO.Response;

public class FruitCountResponse {
    private String fruitType;
    private Long count;

    public FruitCountResponse() {
    }

    public FruitCountResponse(String fruitType, Long count) {
        this.fruitType = fruitType;
        this.count = count;
    }

    public String getFruitType() {
        return fruitType;
    }

    public void setFruitType(String fruitType) {
        this.fruitType = fruitType;
    }

    public Long getCount() {
        return count;
    }

    public void setCount(Long count) {
        this.count = count;
    }
}
