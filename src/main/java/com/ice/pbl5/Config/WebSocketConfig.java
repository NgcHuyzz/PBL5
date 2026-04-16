package com.ice.pbl5.Config;

import com.ice.pbl5.Service.DeviceWebSocketHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {
    private final DeviceWebSocketHandler deviceWebSocketHandler;

    public WebSocketConfig(DeviceWebSocketHandler deviceWebSocketHandler) {
        this.deviceWebSocketHandler = deviceWebSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(deviceWebSocketHandler, "/ws/device")
                .setAllowedOrigins("*");
    }
}
