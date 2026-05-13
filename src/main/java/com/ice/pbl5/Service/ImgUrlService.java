package com.ice.pbl5.Service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Locale;

@Service
public class ImgUrlService {
    @Value("${app.base-url}")
    private String baseUrl;
    private static final String HTTP_PREFIX = "http://";
    private static final String HTTPS_PREFIX = "https://";
    private static final String PUBLIC_IMAGE_PREFIX = "/images";
    private static final String DISK_IMAGE_SEGMENT = "/uploads/images";

    public String buildImgUrl(String imgUrl)
    {
        if (imgUrl == null || imgUrl.isBlank()) {
            return null;
        }

        String normalized = imgUrl.trim().replace('\\', '/');
        String lower = normalized.toLowerCase(Locale.ROOT);

        if (lower.startsWith(HTTP_PREFIX) || lower.startsWith(HTTPS_PREFIX)) {
            return normalized;
        }

        if (normalized.startsWith(PUBLIC_IMAGE_PREFIX)) {
            return joinBaseUrl(normalized);
        }
        if (normalized.startsWith("images/")) {
            return joinBaseUrl("/" + normalized);
        }

        int imageSegmentIdx = lower.indexOf(DISK_IMAGE_SEGMENT);
        if (imageSegmentIdx >= 0) {
            String suffix = normalized.substring(imageSegmentIdx + DISK_IMAGE_SEGMENT.length());
            if (!suffix.startsWith("/")) {
                suffix = "/" + suffix;
            }
            return joinBaseUrl(PUBLIC_IMAGE_PREFIX + suffix);
        }

        if (!normalized.startsWith("/")) {
            normalized = "/" + normalized;
        }
        return joinBaseUrl(normalized);
    }

    private String joinBaseUrl(String path) {
        if (baseUrl == null || baseUrl.isBlank()) {
            return path;
        }
        String trimmedBase = baseUrl.endsWith("/")
                ? baseUrl.substring(0, baseUrl.length() - 1)
                : baseUrl;
        return trimmedBase + path;
    }
}
