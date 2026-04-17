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
        if (imgUrl.startsWith("http://") || imgUrl.startsWith("https://")) {
            return imgUrl;
        }
        if (imgUrl.startsWith("/")) {
            return baseUrl + imgUrl;
        }
        return baseUrl + "/" + imgUrl;
    }
}
