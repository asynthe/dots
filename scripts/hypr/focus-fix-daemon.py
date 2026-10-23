#!/usr/bin/env python3
# Workaround for a known Hyprland quirk: a newly mapped window doesn't
# receive keyboard input until the mouse physically moves (no pointer
# motion event = no focus re-evaluation). spawn-terminal.sh already does
# this nudge for the alt+shift+enter bind; this daemon does it for EVERY
# window open (fuzzel, autostart, anything) by watching the event socket.
import os
import socket
import subprocess

sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
sock_path = f"{runtime}/hypr/{sig}/.socket2.sock"


def nudge():
    pos = subprocess.run(["hyprctl", "cursorpos"], capture_output=True, text=True).stdout.strip()
    x, y = (p.strip() for p in pos.split(","))
    subprocess.run(["hyprctl", "dispatch", f"hl.dsp.cursor.move({{x={x}, y={y}}})"])


def main():
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(sock_path)
    buf = b""
    while True:
        data = s.recv(4096)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            if line.startswith(b"openwindow>>"):
                nudge()


if __name__ == "__main__":
    main()
