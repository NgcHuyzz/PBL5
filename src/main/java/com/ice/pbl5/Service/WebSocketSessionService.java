package com.ice.pbl5.Service;

import org.springframework.stereotype.Service;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class WebSocketSessionService {
    private final Map<UUID, WebSocketSession> sessionsBySystem = new ConcurrentHashMap<>();
    private final Map<String, UUID> systemsBySessionId = new ConcurrentHashMap<>();

    public void register(UUID systemId, WebSocketSession session) {
        sessionsBySystem.put(systemId, session);
        systemsBySessionId.put(session.getId(), systemId);
    }

    public Optional<WebSocketSession> getSession(UUID systemId) {
        return Optional.ofNullable(sessionsBySystem.get(systemId));
    }

    public Optional<UUID> getSystemBySessionId(String sessionId) {
        return Optional.ofNullable(systemsBySessionId.get(sessionId));
    }

    public void removeSession(WebSocketSession session) {
        UUID systemId = systemsBySessionId.remove(session.getId());
        if (systemId != null) {
            sessionsBySystem.remove(systemId);
        }
    }
}
