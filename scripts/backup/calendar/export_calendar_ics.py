#!/usr/bin/env python3
"""Export all events from the user's primary Google Calendar to a .ics file.

Usage (from an activated Hermes-agent env, see SKILL.md Calendar backup section):
    python3 export_calendar_ics.py /path/to/output.ics

Keeps recurring events as recurrence masters (singleEvents=False) instead of
expanding every occurrence, so the .ics stays small and re-importable.
"""
import sys
import os
import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from google_api import build_service  # noqa: E402


def fold(line, limit=75):
    """RFC5545 line folding (naive char-based split; fine for ascii/most text)."""
    out = []
    while len(line.encode("utf-8")) > limit:
        out.append(line[:limit])
        line = " " + line[limit:]
    out.append(line)
    return "\r\n".join(out)


def esc(text):
    if text is None:
        return ""
    return (text.replace("\\", "\\\\")
                .replace(";", "\\;")
                .replace(",", "\\,")
                .replace("\n", "\\n"))


def dt_to_ics(d):
    """d is a Google event start/end dict: {'date': ...} or {'dateTime':..., 'timeZone':...}"""
    if "date" in d:
        return f";VALUE=DATE:{d['date'].replace('-', '')}"
    dt = d["dateTime"]
    tz = d.get("timeZone")
    date_part, time_part = dt.split("T")
    time_clean = time_part.split("+")[0].split("-")[0].split("Z")[0].replace(":", "")
    if tz:
        return f";TZID={tz}:{date_part.replace('-', '')}T{time_clean}"
    elif dt.endswith("Z"):
        return f":{date_part.replace('-', '')}T{time_clean}Z"
    else:
        return f":{date_part.replace('-', '')}T{time_clean}"


def main():
    service = build_service("calendar", "v3")
    time_min = (datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=730)).isoformat()
    time_max = (datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=730)).isoformat()

    events = []
    page_token = None
    while True:
        resp = service.events().list(
            calendarId="primary",
            timeMin=time_min,
            timeMax=time_max,
            singleEvents=False,  # keep recurrence masters intact
            maxResults=2500,
            pageToken=page_token,
        ).execute()
        events.extend(resp.get("items", []))
        page_token = resp.get("nextPageToken")
        if not page_token:
            break

    lines = ["BEGIN:VCALENDAR", "VERSION:2.0",
              "PRODID:-//Hermes//Google Calendar Backup//EN", "CALSCALE:GREGORIAN"]

    for e in events:
        if e.get("status") == "cancelled":
            continue
        lines.append("BEGIN:VEVENT")
        lines.append(fold(f"UID:{e.get('id','')}@google.com"))
        lines.append(fold(f"SUMMARY:{esc(e.get('summary', '(no title)'))}"))
        if "start" in e:
            lines.append(fold(f"DTSTART{dt_to_ics(e['start'])}"))
        if "end" in e:
            lines.append(fold(f"DTEND{dt_to_ics(e['end'])}"))
        if e.get("location"):
            lines.append(fold(f"LOCATION:{esc(e['location'])}"))
        if e.get("description"):
            lines.append(fold(f"DESCRIPTION:{esc(e['description'])}"))
        if e.get("organizer", {}).get("email"):
            lines.append(fold(f"ORGANIZER;CN={esc(e['organizer'].get('displayName',''))}:mailto:{e['organizer']['email']}"))
        for rr in e.get("recurrence", []) or []:
            lines.append(fold(rr))
        lines.append(fold(f"STATUS:{e.get('status','confirmed').upper()}"))
        lines.append("END:VEVENT")

    lines.append("END:VCALENDAR")

    out_path = sys.argv[1] if len(sys.argv) > 1 else "calendar_backup.ics"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\r\n".join(lines) + "\r\n")

    print(f"Exported {len(events)} events to {out_path}")


if __name__ == "__main__":
    main()
