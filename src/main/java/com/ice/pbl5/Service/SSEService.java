package com.ice.pbl5.Service;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class SSEService {
    private final Map<UUID, List<SseEmitter>> emitters = new ConcurrentHashMap<>();

    public SseEmitter register(UUID systemId)
    {
        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
        emitters.computeIfAbsent(systemId, k -> new CopyOnWriteArrayList<>()).add(emitter);

        emitter.onCompletion(() -> removeEmitter(systemId, emitter));
        emitter.onTimeout(()    -> removeEmitter(systemId, emitter));
        emitter.onError(e       -> removeEmitter(systemId, emitter));

        return emitter;
    }

    public void boardcast(UUID systemId, String eventName, Object data)
    {
        List<SseEmitter> li = emitters.getOrDefault(systemId, List.of());
        li.forEach(emitter -> {
            try
            {
                emitter.send(SseEmitter.event()
                        .name(eventName)
                        .data(data, MediaType.APPLICATION_JSON)
                );
            }
            catch (IOException e)
            {
                removeEmitter(systemId, emitter);
            }
        });
    }

    private void removeEmitter(UUID systemId, SseEmitter emitter)
    {
        List<SseEmitter> li = emitters.get(systemId);
        if(li != null)
        {
            li.remove(emitter);
            if(li.isEmpty())
                emitters.remove(systemId);
        }
    }
}
