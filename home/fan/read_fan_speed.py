#!/usr/bin/env python3
from gpiozero import Button
from threading import Lock
import time

TACH_PIN = 13
PULSES_PER_REVOLUTION = 2
WAIT_TIME = 1

fan_tach = Button(TACH_PIN)
pulse_count = 0
pulse_lock = Lock()


def on_pulse():
    global pulse_count
    with pulse_lock:
        pulse_count += 1


fan_tach.when_activated = on_pulse


try:
    last = time.monotonic()
    while True:
        time.sleep(WAIT_TIME)
        now = time.monotonic()
        interval = now - last
        last = now

        with pulse_lock:
            pulses = pulse_count
            pulse_count = 0

        rpm = 0.0
        if interval > 0:
            rpm = (pulses / PULSES_PER_REVOLUTION) * (60 / interval)

        print(f"{rpm:.0f} RPM")
except KeyboardInterrupt:
    raise SystemExit(0)
