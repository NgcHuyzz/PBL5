import threading
import time
from websocket_client import run_event
from hardware.motor_control import motor_stop, motor_forward
from config import DEFAULT_MOTOR_SPEED


def control_loop():
    motor_running = True

    while True:

        if not run_event.is_set():
            if motor_running:
                motor_stop()
                print("[CONTROL] Motor STOP (realtime)")
                motor_running = False

        else:
            if not motor_running:
                motor_forward(DEFAULT_MOTOR_SPEED)
                print("[CONTROL] Motor START (realtime)")
                motor_running = True

        time.sleep(0.01)  # ~10ms


def start_control_thread():
    t = threading.Thread(target=control_loop, daemon=True)
    t.start()
