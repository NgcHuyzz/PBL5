package com.ice.pbl5.Service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;

@Service
public class CloudinaryImageService {
    private final Cloudinary cloudinary;
    private final String folder;
    private final boolean configured;

    public CloudinaryImageService(
            @Value("${cloudinary.cloud-name:}") String cloudName,
            @Value("${cloudinary.api-key:}") String apiKey,
            @Value("${cloudinary.api-secret:}") String apiSecret,
            @Value("${cloudinary.secure:true}") boolean secure,
            @Value("${cloudinary.folder:pbl5}") String folder
    ) {
        this.folder = folder;
        this.configured = isNotBlank(cloudName) && isNotBlank(apiKey) && isNotBlank(apiSecret);

        if (configured) {
            this.cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", cloudName,
                    "api_key", apiKey,
                    "api_secret", apiSecret,
                    "secure", secure
            ));
        } else {
            this.cloudinary = null;
        }
    }

    public String uploadImage(byte[] imageBytes, String extension, UUID systemId, String requestId) throws IOException {
        if (!configured) {
            throw new IllegalStateException("Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET.");
        }
        if (imageBytes == null || imageBytes.length == 0) {
            throw new IllegalArgumentException("Image bytes is empty.");
        }

        String safeRequestId = sanitize(requestId);
        String publicId = systemId + "-" + System.currentTimeMillis() + "-" + safeRequestId;

        @SuppressWarnings("rawtypes")
        Map uploadResult = cloudinary.uploader().upload(imageBytes, ObjectUtils.asMap(
                "folder", folder,
                "public_id", publicId,
                "resource_type", "image",
                "format", normalizeExtension(extension)
        ));

        Object secureUrl = uploadResult.get("secure_url");
        if (secureUrl == null) {
            throw new IOException("Cloudinary upload succeeded but secure_url is missing.");
        }
        return secureUrl.toString();
    }

    private boolean isNotBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private String sanitize(String requestId) {
        if (requestId == null) {
            return UUID.randomUUID().toString();
        }
        String sanitized = requestId.replaceAll("[^a-zA-Z0-9_-]", "_");
        return sanitized.isBlank() ? UUID.randomUUID().toString() : sanitized;
    }

    private String normalizeExtension(String extension) {
        if (extension == null || extension.isBlank()) {
            return "jpg";
        }
        String normalized = extension.trim().toLowerCase();
        if ("jpeg".equals(normalized)) {
            return "jpg";
        }
        return normalized;
    }
}
