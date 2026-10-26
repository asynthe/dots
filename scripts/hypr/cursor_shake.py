#!/usr/bin/env python3
import json
import os
import signal
import socket
import sys
import time

THEME = os.environ.get("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
BASE  = int(os.environ.get("HYPRCURSOR_SIZE", "26"))
BIG   = BASE * 5 // 2

FAST, SLOW = 1 / 60, 1 / 10   # poll rate while moving / while still
IDLE       = 2.0              # seconds without motion before dropping to SLOW
JITTER     = 2                # px per sample below which motion is ignored
MIN_SEG    = 60               # px a stroke must travel before its reversal counts
REVERSALS  = 4                # reversals inside WINDOW that make a shake
WINDOW     = 0.6
HOLD       = 0.5              # seconds the cursor stays big after the last reversal

SOCK = (f"{os.environ['XDG_RUNTIME_DIR']}/hypr/"
        f"{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket.sock")

def ipc(cmd):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(SOCK)
        s.sendall(cmd.encode())
        out = b""
        while chunk := s.recv(4096):
            out += chunk
    return out.decode()

class Axis:
    """Counts direction reversals of strokes long enough to be deliberate."""

    def __init__(self):
        self.dir = 0
        self.travel = 0
        self.flips = []

    def feed(self, d, now):
        if abs(d) < JITTER:
            return
        sign = 1 if d > 0 else -1
        if sign != self.dir:
            if self.dir and self.travel >= MIN_SEG:
                self.flips.append(now)
            self.dir, self.travel = sign, 0
        self.travel += abs(d)

    def shaking(self, now):
        self.flips = [t for t in self.flips if now - t <= WINDOW]
        return len(self.flips) >= REVERSALS

def fullscreen():
    try:
        return json.loads(ipc("j/activewindow") or "{}").get("fullscreen", 0) != 0
    except ValueError:
        return False

def main():
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    ax, ay = Axis(), Axis()
    last = None
    moved = shook = muted = 0.0
    big = False
    failures = 0
    try:
        while True:
            now = time.monotonic()
            try:
                x, y = map(int, ipc("cursorpos").split(","))
                failures = 0
            except (OSError, ValueError):
                failures += 1
                if failures > 20:   # socket gone: Hyprland exited
                    return
                time.sleep(0.5)
                continue

            if last and (x, y) != last:
                moved = now
                ax.feed(x - last[0], now)
                ay.feed(y - last[1], now)
            last = (x, y)

            if (ax.shaking(now) or ay.shaking(now)) and now >= muted:
                if fullscreen():
                    muted = now + 1.0
                else:
                    shook = max(ax.flips[-1:] + ay.flips[-1:])
                    if not big:
                        ipc(f"setcursor {THEME} {BIG}")
                        big = True

            if big and now - shook > HOLD:
                ipc(f"setcursor {THEME} {BASE}")
                big = False

            time.sleep(FAST if now - moved < IDLE else SLOW)
    finally:
        if big:
            try:
                ipc(f"setcursor {THEME} {BASE}")
            except OSError:
                pass

if __name__ == "__main__":
    main()
