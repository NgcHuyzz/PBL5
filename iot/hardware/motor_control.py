import RPi.GPIO as GPIO
import time
from config import PWMA, AIN1, AIN2

GPIO.setmode(GPIO.BCM)

GPIO.setup(PWMA, GPIO.OUT)
GPIO.setup(AIN1, GPIO.OUT)
GPIO.setup(AIN2, GPIO.OUT)

pwm = GPIO.PWM(PWMA, 1000)  # 1kHz
pwm.start(0)

current_speed = 0  


def set_speed(speed):
    global current_speed
    speed = max(0, min(100, speed))  
    pwm.ChangeDutyCycle(speed)
    current_speed = speed


def motor_forward(speed=50):
    GPIO.output(AIN1, 1)
    GPIO.output(AIN2, 0)
    set_speed(speed)


def motor_backward(speed=50):
    GPIO.output(AIN1, 0)
    GPIO.output(AIN2, 1)
    set_speed(speed)


def motor_stop():
    set_speed(0)


def motor_ramp(target_speed, step=5, delay=0.05):
    global current_speed

    if target_speed > current_speed:
        for s in range(current_speed, target_speed + 1, step):
            set_speed(s)
            time.sleep(delay)
    else:
        for s in range(current_speed, target_speed - 1, -step):
            set_speed(s)
            time.sleep(delay)
