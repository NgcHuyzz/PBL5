package com.ice.pbl5.Service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ImgUrlService {
    @Value("${app.base-url}")
    private String baseUrl;

    public String buildImgUrl(String imgUrl)
    {
        if (imgUrl == null || imgUrl.isBlank()) {
            return null;
        }
        return baseUrl+ imgUrl;
    }
}
