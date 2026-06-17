#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

PHONE_IP     = "192.168.1.41"
MUSIC_SOURCE = Path("/home/meow/music")
MUSIC_DEST   = "/sdcard/Music"


def run(cmd, check=True):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if check and r.returncode != 0:
        print(f"adb error: {r.stderr.strip()}", file=sys.stderr)
        sys.exit(1)
    return r.stdout.strip()


def adb_shell(cmd):
    return run(["adb", "shell", cmd])


def connect():
    print(f"Connecting to {PHONE_IP} ...")
    out = run(["adb", "connect", PHONE_IP], check=False)
    print(out)
    devices = run(["adb", "devices"])
    if PHONE_IP not in devices:
        print("Could not connect. Check IP and that wireless debugging is on.", file=sys.stderr)
        sys.exit(1)


def phone_flac_files():
    out = adb_shell(f"find '{MUSIC_DEST}' -type f -iname '*.flac' 2>/dev/null")
    if not out:
        return set()
    prefix = MUSIC_DEST.rstrip("/") + "/"
    return {line.removeprefix(prefix) for line in out.splitlines() if line.startswith(prefix)}


def local_flac_files():
    return {
        str(p.relative_to(MUSIC_SOURCE)): p
        for p in MUSIC_SOURCE.rglob("*")
        if p.is_file() and p.suffix.lower() == ".flac"
    }


def main():
    connect()

    print("\nScanning phone ...")
    on_phone = phone_flac_files()
    print(f"  {len(on_phone)} .flac files found on phone")

    print("Scanning laptop ...")
    on_laptop = local_flac_files()
    print(f"  {len(on_laptop)} .flac files found on laptop")

    if len(on_laptop) == 0 and len(on_phone) > 0:
        print(f"\nSafeguard: local has 0 files but phone has {len(on_phone)}. Aborting.", file=sys.stderr)
        sys.exit(1)

    if len(on_phone) > len(on_laptop):
        print(
            f"\nSafeguard: phone has more files ({len(on_phone)}) than laptop ({len(on_laptop)}). Aborting.",
            file=sys.stderr,
        )
        sys.exit(1)

    missing = {rel: path for rel, path in on_laptop.items() if rel not in on_phone}

    if not missing:
        print("\nNothing to do — phone is already up to date.")
        return

    print(f"\n{len(missing)} file(s) to transfer:")
    for rel in sorted(missing):
        print(f"  {rel}")

    print()
    for i, (rel, local_path) in enumerate(sorted(missing.items()), 1):
        dest_path = f"{MUSIC_DEST}/{rel}"
        dest_dir  = str(Path(dest_path).parent).replace("\\", "/")
        adb_shell(f"mkdir -p '{dest_dir}'")
        print(f"[{i}/{len(missing)}] {rel}")
        run(["adb", "push", str(local_path), dest_path])

    print("\nDone.")


if __name__ == "__main__":
    main()
