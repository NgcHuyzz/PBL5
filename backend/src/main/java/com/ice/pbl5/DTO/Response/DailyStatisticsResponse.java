package com.ice.pbl5.DTO.Response;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

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

    public DailyStatisticsResponse(Object date, Long totalClassified) {
        this.date = convertToLocalDate(date);
        this.totalClassified = totalClassified != null ? totalClassified : 0L;
    }

    private static LocalDate convertToLocalDate(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof LocalDate localDate) {
            return localDate;
        }
        if (value instanceof LocalDateTime localDateTime) {
            return localDateTime.toLocalDate();
        }
        if (value instanceof Date sqlDate) {
            return sqlDate.toLocalDate();
        }
        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime().toLocalDate();
        }
        if (value instanceof java.util.Date utilDate) {
            return new Date(utilDate.getTime()).toLocalDate();
        }
        throw new IllegalArgumentException("Unsupported date type: " + value.getClass().getName());
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
