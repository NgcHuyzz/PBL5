package com.ice.pbl5.DTO.Response;

import java.sql.Date;
import java.sql.Timestamp;
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

    public DailyStatisticsResponse(Date date, long totalClassified) {
        this(date != null ? date.toLocalDate() : null, totalClassified);
    }

    public DailyStatisticsResponse(Timestamp date, long totalClassified) {
        this(date != null ? date.toLocalDateTime().toLocalDate() : null, totalClassified);
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
