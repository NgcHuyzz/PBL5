import websocket
import threading
import json
import base64
import uuid
import time
import os

from system_manager import get_system_id
from threading import Event, Lock

WS_URL = "ws://192.168.137.212:8088/ws/device"
SYSTEM_ID = get_system_id()

ws = None
connected_event = Event()
run_event = Event()
run_event.set()
# =========================
# EVENT STORAGE
# =========================
result_events = {}
result_data = {}

send_lock = Lock()
result_lock = Lock()


# =========================
# CALLBACKS
# =========================

def on_message(ws_app, message):
    try:
        data = json.loads(message)
    except Exception as e:
        print("[WS ERROR] Invalid JSON:", e)
        return

    msg_type = data.get("type")
    request_id = data.get("requestId")

    if msg_type == "accepted":
        pass

    elif msg_type == "result":
        with result_lock:
            result_data[request_id] = {
                "label": data.get("fruitType"),
                "confidence": data.get("confidence")
            }

            if request_id in result_events:
                result_events[request_id].set()
    elif msg_type == "command":
        command = data.get("command")

        if command == "stop_conveyor":
            run_event.clear()
            print("[COMMAND] STOP")

        elif command == "start_conveyor":
            run_event.set()
            print("[COMMAND] START")

def on_open(ws_app):
    print("[WS] Connected")

    ws_app.send(json.dumps({
        "type": "register",
        "systemId": SYSTEM_ID
    }))

    connected_event.set()


def on_close(ws_app, close_status_code, close_msg):
    print("[WS] Disconnected")
    connected_event.clear()


def on_error(ws_app, error):
    print("[WS ERROR]", error)
    connected_event.clear()


# =========================
# CONNECT
# =========================

def connect():
    global ws

    def run():
        global ws

        while True:
            try:
                connected_event.clear()

                ws = websocket.WebSocketApp(
                    WS_URL,
                    on_message=on_message,
                    on_open=on_open,
                    on_close=on_close,
                    on_error=on_error
                )

                ws.run_forever()

            except Exception as e:
                print("[WS] crash -> reconnect:", e)
                time.sleep(2)

    threading.Thread(target=run, daemon=True).start()


def is_connected():
    return ws is not None and ws.sock is not None and ws.sock.connected


# =========================
# SEND PREDICT
# =========================

def send_predict(image_path):
    if not connected_event.wait(timeout=10):
        raise Exception("WebSocket not connected")

    if not is_connected():
        raise Exception("WebSocket socket not ready")

    request_id = str(uuid.uuid4())

    event = Event()
    with result_lock:
        result_events[request_id] = event

    try:
        with open(image_path, "rb") as f:
            image_base64 = base64.b64encode(f.read()).decode("utf-8")

        msg = {
            "type": "predict",
            "systemId": SYSTEM_ID,
            "requestId": request_id,
            "imageBase64": image_base64
        }

        with send_lock:
            ws.send(json.dumps(msg))

        return request_id

    finally:
        if image_path and os.path.exists(image_path):
            try:
                os.remove(image_path)
                print(f"[CLEANUP] Deleted image: {image_path}")
            except Exception as e:
                print(f"[CLEANUP ERROR] Cannot delete {image_path}: {e}")


# =========================
# GET RESULT (BLOCKING SAFE)
# =========================

def get_result(request_id, timeout=5):
    with result_lock:
        event = result_events.get(request_id)

    if not event:
        return None

    is_set = event.wait(timeout)

    with result_lock:
        if is_set:
            result = result_data.pop(request_id, None)
            result_events.pop(request_id, None)
            return result

        # timeout -> cleanup luon
        result_events.pop(request_id, None)
        result_data.pop(request_id, None)
        return None
