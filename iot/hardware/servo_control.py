import RPi.GPIO as GPIO
import time
from config import (
    G1, G2, G3, G4,
    SERVO_G1_HOME, SERVO_G1_PUSH,
    SERVO_G2_HOME, SERVO_G2_PUSH,
    SERVO_G3_HOME, SERVO_G3_PUSH,
    SERVO_G4_HOME, SERVO_G4_PUSH,
    HOLD_BLUEBERRY, HOLD_GRAPE, HOLD_STRAWBERRY, HOLD_CHERRY_TOMATO
)

servo_pins = [G1, G2, G3, G4]
servo_pwm = {}

GPIO.setmode(GPIO.BCM)

for pin in servo_pins:
    GPIO.setup(pin, GPIO.OUT)
    pwm = GPIO.PWM(pin, 50)
    pwm.start(0)
    servo_pwm[pin] = pwm


def set_angle(pin, angle):
    duty = 2 + (angle / 18)
    servo_pwm[pin].ChangeDutyCycle(duty)
    time.sleep(0.4)
    servo_pwm[pin].ChangeDutyCycle(0)


def sort_fruit(label):
    print("[SERVO] sorting:", label)

    if label == "BLUEBERRY":
        pin = G4
        home_angle = SERVO_G4_HOME
        push_angle = SERVO_G4_PUSH
        hold_time = HOLD_BLUEBERRY

    elif label == "GRAPE":
        pin = G2
        home_angle = SERVO_G2_HOME
        push_angle = SERVO_G2_PUSH
        hold_time = HOLD_GRAPE

    elif label == "STRAWBERRY":
        pin = G3
        home_angle = SERVO_G3_HOME
        push_angle = SERVO_G3_PUSH
        hold_time = HOLD_STRAWBERRY

    elif label == "CHERRY TOMATO":
        pin = G1
        home_angle = SERVO_G1_HOME
        push_angle = SERVO_G1_PUSH
        hold_time = HOLD_CHERRY_TOMATO

    else:
        print("[SERVO] unknown label -> skip")
        return

    set_angle(pin, home_angle)
    time.sleep(0.1)

    set_angle(pin, push_angle)
    time.sleep(hold_time)

    set_angle(pin, home_angle)
    time.sleep(0.2)
