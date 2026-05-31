import RPi.GPIO as GPIO
import time
from statistics import median
from config import TRIG_PIN, ECHO_PIN, DISTANCE_THRESHOLD_CM

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

GPIO.setup(TRIG_PIN, GPIO.OUT)
GPIO.setup(ECHO_PIN, GPIO.IN)

GPIO.output(TRIG_PIN, False)
time.sleep(0.5)

_last_detect_time = 0
DETECTION_COOLDOWN = 0.8


def get_distance():
    GPIO.output(TRIG_PIN, False)
    time.sleep(0.0002)

    # phat xung trigger
    GPIO.output(TRIG_PIN, True)
    time.sleep(0.00001)
    GPIO.output(TRIG_PIN, False)

    pulse_start = None
    pulse_end = None

    timeout = time.time() + 0.03

    # cho echo len 1
    while GPIO.input(ECHO_PIN) == 0:
        pulse_start = time.time()
        if pulse_start > timeout:
            return None

    timeout = time.time() + 0.03

    # cho echo xuong 0
    while GPIO.input(ECHO_PIN) == 1:
        pulse_end = time.time()
        if pulse_end > timeout:
            return None

    if pulse_start is None or pulse_end is None:
        return None

    pulse_duration = pulse_end - pulse_start
    distance = pulse_duration * 34300 / 2

    if distance <= 0 or distance > 400:
        return None

    return distance


def get_stable_distance(samples=5, delay=0.01):
    values = []

    for _ in range(samples):
        d = get_distance()
        if d is not None:
            values.append(d)
        time.sleep(delay)

    if not values:
        return None

    return median(values)


def is_object_at_camera():
    global _last_detect_time

    now = time.time()

    if now - _last_detect_time < DETECTION_COOLDOWN:
        return False

    distance = get_stable_distance()

    if distance is None:
        return False

    detected = distance < DISTANCE_THRESHOLD_CM

    if detected:
        _last_detect_time = now

    return detected
