package com.ice.pbl5.DTO.Response;

import java.time.LocalDate;

public class DailyStatisticsResponse {
    private LocalDate date;
    private long totalClassified;

    public DailyStatisticsResponse() {
    }

    public DailyStatisticsResponse(LocalDate date, long totalClassified) {
        this.totalClassified = totalClassified;
        this.date = date;
    }

    public long getTotalClassified() {
        return totalClassified;
    }

    public void setTotalClassified(long totalClassified) {
        this.totalClassified = totalClassified;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }
}
