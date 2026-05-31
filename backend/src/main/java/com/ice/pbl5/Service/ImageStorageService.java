package com.ice.pbl5.Service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;

@Service
public class ImageStorageService {

    @Value("${storage.type}")
    private String storageType;

    public byte[] readImage(String imageUrl) throws IOException {
        if ("local".equals(storageType)) {
            return Files.readAllBytes(Path.of(imageUrl));
        } else {
            return new URL(imageUrl).openStream().readAllBytes();
        }
    }
}
