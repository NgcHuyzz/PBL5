package com.ice.pbl5.DTO.Request;

public class FruitConfigItemRequest {
    private String fruitName;
    private String targetBin;

    public FruitConfigItemRequest() {
    }

    public FruitConfigItemRequest(String fruitName, String targetBin) {
        this.fruitName = fruitName;
        this.targetBin = targetBin;
    }

    public String getFruitName() {
        return fruitName;
    }

    public void setFruitName(String fruitName) {
        this.fruitName = fruitName;
    }

    public String getTargetBin() {
        return targetBin;
    }

    public void setTargetBin(String targetBin) {
        this.targetBin = targetBin;
    }
}
