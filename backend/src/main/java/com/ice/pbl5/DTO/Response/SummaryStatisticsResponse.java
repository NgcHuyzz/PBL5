package com.ice.pbl5.DTO.Response;

public class SummaryStatisticsResponse {
    private long totalReceived;
    private long totalProcessing;
    private long totalCompleted;
    private long totalFailed;
    private Double averageProcessingTimeMs;

    public SummaryStatisticsResponse() {
    }

    public SummaryStatisticsResponse(long totalReceived, long totalProcessing, long totalCompleted, long totalFailed, Double averageProcessingTimeMs) {
        this.totalReceived = totalReceived;
        this.totalProcessing = totalProcessing;
        this.totalCompleted = totalCompleted;
        this.totalFailed = totalFailed;
        this.averageProcessingTimeMs = averageProcessingTimeMs;
    }

    public long getTotalReceived() {
        return totalReceived;
    }

    public void setTotalReceived(long totalReceived) {
        this.totalReceived = totalReceived;
    }

    public long getTotalProcessing() {
        return totalProcessing;
    }

    public void setTotalProcessing(long totalProcessing) {
        this.totalProcessing = totalProcessing;
    }

    public long getTotalCompleted() {
        return totalCompleted;
    }

    public void setTotalCompleted(long totalCompleted) {
        this.totalCompleted = totalCompleted;
    }

    public long getTotalFailed() {
        return totalFailed;
    }

    public void setTotalFailed(long totalFailed) {
        this.totalFailed = totalFailed;
    }

    public Double getAverageProcessingTimeMs() {
        return averageProcessingTimeMs;
    }

    public void setAverageProcessingTimeMs(Double averageProcessingTimeMs) {
        this.averageProcessingTimeMs = averageProcessingTimeMs;
    }
}
