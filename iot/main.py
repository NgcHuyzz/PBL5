import time
import RPi.GPIO as GPIO

from camera.camera_capture import capture_image, release_camera
from ai.ai_client import predict
from websocket_client import get_result, connect, connected_event
from hardware.sensor import is_object_at_camera
from hardware.servo_control import sort_fruit
from hardware.motor_control import motor_forward, motor_stop
from config import CAPTURE_DELAY, DEFAULT_MOTOR_SPEED, RESULT_TIMEOUT
from control_thread import start_control_thread


# =========================
# INIT
# =========================

connect()
start_control_thread()

print("[SYSTEM] Waiting WebSocket connection...")

if not connected_event.wait(timeout=10):
    raise Exception("WebSocket connection failed")

print("[SYSTEM] WebSocket connected")

motor_forward(DEFAULT_MOTOR_SPEED)


# =========================
# MAIN LOOP
# =========================

try:
    while True:

        if is_object_at_camera():
            print("[SYSTEM] Object detected")

            # 1. dung bang chuyen
            motor_stop()
            print("[SYSTEM] Motor stopped")

            # 2. doi on dinh roi chup
            time.sleep(CAPTURE_DELAY)

            img = capture_image()

            if img is None:
                print("[SCAN ERROR] Capture failed")
                motor_forward(DEFAULT_MOTOR_SPEED)
                time.sleep(0.5)
                continue

            # 3. chay bang chuyen lai ngay sau khi chup
            motor_forward(DEFAULT_MOTOR_SPEED)
            print("[SYSTEM] Motor resumed")

            try:
                # 4. gui anh len server
                request_id = predict(img)
                print("[SCAN] request_id:", request_id)

                # 5. doi ket qua tra ve
                result = get_result(request_id, timeout=RESULT_TIMEOUT)

                if result is None:
                    print("[RESULT] Timeout -> skip")
                    time.sleep(0.5)
                    continue

                label = result.get("label")
                print("[RESULT] label:", label)

                # 6. gat servo theo label server tra ve
                #if label:
                #    sort_fruit(label)

            except Exception as e:
                print("[SYSTEM ERROR]", e)

            # chong nhan lap cung 1 qua
            time.sleep(0.8)

        time.sleep(0.05)

except KeyboardInterrupt:
    print("\n[SYSTEM] Stopping...")

finally:
    print("[SYSTEM] Cleaning up...")

    try:
        motor_stop()   
    except:
        pass

    release_camera()
    GPIO.cleanup()

    print("[SYSTEM] Stopped completely")
