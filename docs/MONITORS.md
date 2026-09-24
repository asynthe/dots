# Monitors

`config/hypr/monitors.lua`: which output is where, which workspaces live on it,
and what happens when one disappears. A new display is matched by EDID
description; the ones seen so far are:

```
@@@ 5655SMART TV 0x00011011
HP Inc. HP P24v G4 1CR10315PN
Hisense Electric Co. Ltd. HISENSE 0x00000001
LG Electronics LG TV 0x01010101
Nreal MGMG2710C
Panasonic Industry Company Panasonic-TV 0x01010101
SANTAK CORP. S2-TEK TV SN-000000001
Samsung Electric Company S34CG50 HNBYC00076
Samsung Electric Company SAMSUNG 0x01000E00
Sony SONY TV 0x01010101
```

`hyprctl monitors all` prints the description of whatever is plugged in now.
The laptop panel is `AU Optronics 0xB0AE`, 1920 wide.

## Sides and the sticky flag

`side` is `"left"` or `"right"` and says where the laptop sits relative to the
external. The panel's off-state is **sticky**: once it has been explicitly
turned off, a hotplug — a TV dropping its link on standby — must not resurrect
it through `apply_monitors()`.

## Workspaces

The panel keeps 1–2, the external takes 3–10. Low numbers sit on the left screen
while `side == "left"`, so the ids read across the desk.

**The rules are never torn down on a disconnect.** A monitor that drops its DP
link in standby needs them already in place when it comes back, because Hyprland
relocates workspaces before Lua runs. `session.sh`'s `empty_workspaces()` scans
the external's block and has to move with that number.

A workspace rule binds a workspace when it is *created*, not when a monitor
returns — so everything the panel owned is still on the external after a lid
cycle, and everything the external owned is still on the panel after a hotplug.
The fix walks the live workspaces and pushes the strays back; it is idempotent,
and a workspace already on the right screen is not touched.

## Timing

Reconfiguration is delayed: a monitor restoring its link while the panel is
still dpms-off will otherwise claim the internal's crtc slot before the new
layout is applied.

The laptop-screen toggle checks live state, so the lid switch cannot desync it.
