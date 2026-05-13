import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SseEvent {
  final String event;
  final Map<String, dynamic> data;

  const SseEvent({required this.event, required this.data});
}

class SseService {
  /// Returns a broadcast stream of SSE events. Auto-reconnects on disconnect.
  /// Cancel the [StreamSubscription] to stop and disconnect.
  static Stream<SseEvent> subscribe({
    required String baseUrl,
    required String systemId,
    required String token,
  }) {
    late StreamController<SseEvent> controller;
    http.Client? client;
    bool cancelled = false;

    Future<void> connect({int retrySeconds = 3}) async {
      if (cancelled) return;

      client = http.Client();
      try {
        final uri = Uri.parse('$baseUrl/sse/stream').replace(
          queryParameters: {'systemId': systemId},
        );

        final request = http.Request('GET', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final response = await client!.send(request);

        if (response.statusCode != 200) {
          client?.close();
          client = null;
          if (!cancelled) {
            await Future.delayed(Duration(seconds: retrySeconds));
            await connect(retrySeconds: (retrySeconds * 2).clamp(3, 30));
          }
          return;
        }

        String buffer = '';
        String eventName = '';
        String eventData = '';

        await for (final chunk in response.stream.transform(utf8.decoder)) {
          if (cancelled) break;
          buffer += chunk;

          while (buffer.contains('\n')) {
            final lineEnd = buffer.indexOf('\n');
            final line = buffer.substring(0, lineEnd).replaceAll('\r', '');
            buffer = buffer.substring(lineEnd + 1);

            if (line.isEmpty) {
              if (eventName.isNotEmpty && eventData.isNotEmpty && !cancelled) {
                try {
                  final decoded = jsonDecode(eventData);
                  if (decoded is Map<String, dynamic>) {
                    controller.add(SseEvent(event: eventName, data: decoded));
                  }
                } catch (_) {}
              }
              eventName = '';
              eventData = '';
            } else if (line.startsWith('event:')) {
              eventName = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              eventData += line.substring(5).trim();
            }
          }
        }
      } catch (_) {
        // connection dropped — fall through to reconnect
      } finally {
        client?.close();
        client = null;
      }

      if (!cancelled) {
        await Future.delayed(Duration(seconds: retrySeconds));
        await connect(retrySeconds: (retrySeconds * 2).clamp(3, 30));
      }
    }

    controller = StreamController<SseEvent>(
      onCancel: () {
        cancelled = true;
        client?.close();
        client = null;
      },
    );

    connect();
    return controller.stream;
  }
}
