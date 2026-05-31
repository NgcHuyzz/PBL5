from picamera2 import Picamera2
import cv2
import time

picam2 = Picamera2()
picam2.preview_configuration.main.size = (640, 480)
picam2.preview_configuration.main.format = "RGB888"
picam2.configure("preview")
picam2.start()


def capture_image():
    try:
        frame = picam2.capture_array()
        path = f"image_{int(time.time() * 1000)}.jpg"

        ok = cv2.imwrite(path, frame)
        if not ok:
            return None

        print(f"[Camera] da chup: {path}")
        return path

    except Exception as e:
        print("[Camera ERROR]", e)
        return None


def release_camera():
    picam2.stop()
    print("[Camera] da dung")
