#!/usr/bin/env python3
from enum import Enum
from gpiozero import PWMOutputDevice
import os
import signal
import sys
import time

# Noctua PWM spec is around 25 kHz, but on this hardware/backend we intentionally
# use 100 Hz to keep lower stable RPM control.
PWM_FREQ_HZ = 100

PWM_PIN = 12
TACH_PIN = 13
WAIT_TIME = 1

OFF_TEMP = 40
MIN_TEMP = 45
MAX_TEMP = 70

FAN_PROFILE_PATH = "/etc/fan-control/profile"


class FanProfile(Enum):
    LINEAR = "linear"
    EASE_IN = "ease_in"
    EASE_OUT = "ease_out"
    EASE_IN_OUT = "ease_in_out"

    @classmethod
    def from_string(cls, value: str):
        normalized = value.strip().lower()
        mapping = {
            "linear": cls.LINEAR,
            "ease_in": cls.EASE_IN,
            "ease_out": cls.EASE_OUT,
            "ease_in_out": cls.EASE_IN_OUT,
        }
        return mapping.get(normalized)


def get_cpu_temperature():
    with open("/sys/class/thermal/thermal_zone0/temp", encoding="utf-8") as handle:
        return float(handle.read()) / 1000


def clamp_speed(speed: float) -> float:
    return max(0.0, min(1.0, speed))


def normalize_temperature(temperature: float) -> float:
    if MAX_TEMP <= MIN_TEMP:
        return 1.0 if temperature >= MAX_TEMP else 0.0
    if temperature <= MIN_TEMP:
        return 0.0
    if temperature >= MAX_TEMP:
        return 1.0
    return (temperature - MIN_TEMP) / (MAX_TEMP - MIN_TEMP)


def linear_curve(progress: float) -> float:
    return progress


def ease_in_curve(progress: float) -> float:
    return progress * progress * progress


def ease_out_curve(progress: float) -> float:
    return (progress - 1) * (progress - 1) * (progress - 1) + 1


def ease_in_out_curve(progress: float) -> float:
    if progress < 0.5:
        return 0.5 * ease_in_curve(2 * progress)
    return 0.5 * ease_out_curve(2 * progress - 1) + 0.5


def select_curve(profile: FanProfile):
    if profile == FanProfile.EASE_IN:
        return ease_in_curve
    if profile == FanProfile.EASE_OUT:
        return ease_out_curve
    if profile == FanProfile.EASE_IN_OUT:
        return ease_in_out_curve
    return linear_curve


def get_profile_override():
    try:
        with open(FAN_PROFILE_PATH, encoding="utf-8") as handle:
            raw = handle.read().strip()
    except FileNotFoundError:
        return None
    except OSError as exc:
        print(
            f"{FAN_PROFILE_PATH}: read failed ({exc}); defaulting to linear.",
            file=sys.stderr,
        )
        return None

    if not raw:
        return None

    profile = FanProfile.from_string(raw)
    if profile is None:
        print(
            f"{FAN_PROFILE_PATH}: unknown profile '{raw}'; defaulting to linear.",
            file=sys.stderr,
        )
    return profile


def get_lgpio_factory():
    try:
        from gpiozero.pins.lgpio import LGPIOFactory
    except Exception as exc:  # pragma: no cover - hardware/runtime dependent
        print(
            f"LGPIOFactory unavailable ({exc}); falling back to default pin factory.",
            file=sys.stderr,
        )
        return None

    try:
        return LGPIOFactory()
    except Exception as exc:  # pragma: no cover - hardware/runtime dependent
        print(
            f"Failed to initialize LGPIOFactory ({exc}); using default pin factory.",
            file=sys.stderr,
        )
        return None


def ensure_working_dir():
    try:
        cwd = os.getcwd()
    except FileNotFoundError:
        cwd = None

    if not cwd or not os.path.isdir(cwd):
        fallback = "/tmp"
        print(
            "Working directory missing; lgpio needs a writable directory for "
            f"its .lgd-nfy* pipe. Falling back to {fallback}.",
            file=sys.stderr,
        )
        os.chdir(fallback)
        return

    if not os.access(cwd, os.W_OK):
        fallback = "/tmp"
        print(
            f"Working directory '{cwd}' is not writable; lgpio needs a writable "
            f"directory for its .lgd-nfy* pipe. Falling back to {fallback}.",
            file=sys.stderr,
        )
        os.chdir(fallback)


def pwm_for_temperature(temperature: float, curve_fn) -> float:
    if temperature <= OFF_TEMP:
        return 0.0
    if temperature < MIN_TEMP:
        return 0.0
    progress = normalize_temperature(temperature)
    return clamp_speed(curve_fn(progress))


def handle_fan_speed(fan_device: PWMOutputDevice, temperature: float, curve_fn):
    speed = pwm_for_temperature(temperature, curve_fn)
    if speed <= 0.0:
        fan_device.off()
    else:
        fan_device.value = speed


def main():
    signal.signal(signal.SIGTERM, lambda *_args: sys.exit(0))
    ensure_working_dir()

    pin_factory = get_lgpio_factory()
    fan_device = PWMOutputDevice(PWM_PIN, pin_factory=pin_factory)

    try:
        fan_device.frequency = PWM_FREQ_HZ
    except Exception as exc:  # pragma: no cover - hardware/runtime dependent
        print(
            f"Failed to set PWM frequency to {PWM_FREQ_HZ}Hz: {exc}. Using default.",
            file=sys.stderr,
        )

    profile = get_profile_override() or FanProfile.LINEAR
    curve_fn = select_curve(profile)

    while True:
        handle_fan_speed(fan_device, get_cpu_temperature(), curve_fn)
        time.sleep(WAIT_TIME)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
