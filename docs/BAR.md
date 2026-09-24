# bar

The top-edge strip. `config/quickshell/bar/` — an ordinary quickshell config,
symlinked into place like everything else under `config/`.

```
meow@p1        Sin Servicio 5G   vpn   ▁▃▅▇ 10.135.39.20 │ ▆▆░░ 42% │ 03:42
```

Left is who and where. Right is the link: the network's name, a `vpn` tag when
the default route leaves through a tunnel, then the signal bars and the address
as one unit, then the battery, then the time. That is the whole surface — no
tray, no workspaces, no media.

The bars sit against the address deliberately: they are the health of the path
that address is reachable through, so they read as one thing and share one
click target. The address is white — it is a fact, not a status. The bars carry
the colour.

## The battery

Four segments and a percentage, between the address and the clock, each group
fenced by a hairline. It is the one readout on the strip that is not about the
link, and the only one that earned its width by being the thing you need to
know before the machine decides for you.

**The segments are equal height, where the signal bars rise.** A charge level
is a fraction of a whole; signal strength is a magnitude. Same material, and
the shape alone says which you are looking at without reading the number.

Lit count is `ceil(pct / 25)`, so any charge at all lights the first segment.
An empty row would read as "no battery", which is a different thing from
"nearly flat".

The percentage is coloured, unlike the address beside it, because it is a
status rather than a fact: `fg` above 30%, `warn` at 30 and below, `crit` at 15
and below. On AC it is the accent at any level — a pack at 8% on the charger is
not a problem to flag — and the group pulses while it is actually filling, but
holds steady once full so a docked machine is not blinking at you all day.

The source is UPower's display device, which is the aggregate pack, already
merged on a machine with two. `isLaptopBattery` keeps a bluetooth mouse from
ever appearing here, and the whole group is hidden when no pack is present, so
a desktop shows nothing rather than an empty gauge.

    qs -c bar                        # run
    qs -c bar ipc call bar toggle    # ALT + SHIFT + B
    qs -c bar ipc call bar menu      # the name menu, without clicking
    qs -c bar ipc call bar addresses # the address menu, without clicking
    qs -c bar ipc call bar state     # what it currently believes, as text

Started from `config/hypr/hyprland.lua` with `uwsm app -- qs -c bar`, the same
way awww-daemon is. No systemd unit: it is a plain quickshell config, not a
compiled install with store paths to keep alive, so there is nothing for a unit
to protect.

`ALT + SHIFT + B` is a plain show/hide, with no marker file: bar has no
auto-hide, so there is no hidden state to remember which way the toggle went.
The layer namespace is plain `quickshell`, which the `layer_rule` blur and the
hyprglass layer exclusion in `hyprland.lua` already match.

## Notifications are mako's

bar draws no notifications. mako owns the DBus name and draws them itself —
`config/mako/config` is a normal visible mako. It used to run `invisible=1`,
feeding a shell that rendered them; nothing does that now, so the setting came
out with it.

## The name menu

Clicking `meow@p1` drops a panel in the shape the classic desktops used:
square corners, a hard offset shadow with no blur, separators, and full-width
inversion on hover. The name itself stays inverted while the panel is down, the
way a held-open menu title did. There is **no border** — the shadow is what
separates it from the wallpaper, and an accent outline on top of that was
drawing the frame twice.

    qs -c bar ipc call bar menu             # open it without clicking
    qs -c bar ipc call bar pane audio       # open it on a given pane

Header is hostname, kernel and uptime. Uptime is read only when the panel
opens, since that is the only time it shows.

Below it, a rail of five panes on the left and that pane's readings plus its
apps on the right. It opens on **System**, which is fastfetch — clicking your
own hostname asks "what is this machine", and that is fastfetch's question.
The rest of the rail is there once you are already looking.

| Pane | Shows | Launches |
| --- | --- | --- |
| System | OS, host, kernel, uptime, packages, WM, CPU, GPUs, memory, swap, battery, locale | btop, htop, yazi, ghostty, codium, fuzzel |
| Network | interface, gateway, DNS, MAC, rx/tx totals, other interfaces that are up | impala, iwctl, Mullvad, qBittorrent, Firefox, copy IP, rescan |
| Audio | output, volume, input, sample rate, buffer and its latency, active streams | pavucontrol, wiremix, cava, ncmpcpp, Mixxx, mpv |
| Display | each monitor's mode, refresh, scale and focus, backlight, GPUs | reload WM, restore wallpaper, brightness ±, Steam |
| Storage | mounts deduplicated by device, physical disks | yazi at `~`, `~/archive`, `~/git`, ncdu, qBittorrent |

Selecting a pane does not close the panel — the point is reading one after
another. Launching an app does; `Copy IP`, `Rescan` and the brightness steps
carry `stay: true` and keep it up, because each of them changes something the
pane is displaying.

`Reload bar` and `Log Out…` sit in the footer rather than the rail: they act on
the strip, not on a category.

Add a pane by appending to `menuPanes` in `shell.qml` — `{ id, label, apps }`,
where each app is `{ label, act }` plus an optional `stay` — and a matching
case to `sysinfo.sh`. Nothing else counts them.

### Where the readings come from

`sysinfo.sh <pane>` prints `key \t value` lines and the QML draws whatever
comes back, in order. Every pane is a sub-100ms probe (measured — system is
the slowest at ~100ms, storage the fastest at ~10ms), so there is no spinner:
the previous rows stay up and are replaced in one frame. Rows are cached per
pane, so going back to one you have already opened paints immediately.

The system pane trims fastfetch's strings rather than reproducing them, because
fastfetch appends the things a terminal fetch wants and a menu does not:

| fastfetch | pane |
| --- | --- |
| `NixOS 26.11 (Zokor) x86_64` | `NixOS 26.11 (Zokor)` |
| `21KV003PCL (ThinkPad P1 Gen 7)` | `ThinkPad P1 Gen 7` |
| `Hyprland 0.56.2 (Wayland)` | `Hyprland 0.56.2` |
| `Intel(R) Core(TM) Ultra 7 155H (12+8+2) @ 4.80 GHz` | `Intel(R) Core(TM) Ultra 7 155H` |
| `NVIDIA RTX 2000 Ada Generation Laptop GPU` | `NVIDIA RTX 2000` |
| `en_US.UTF-8` | `English (en_US.UTF-8)` |

The bare machine-type code identifies nothing to a human, so `Host` keeps the
parenthetical and drops the code — falling through unchanged on a machine that
reports only one of the two. **Memory and swap are gone**: they are a gauge's
job, not a static readout's.

`GPU` is the discrete card only. This machine is on PRIME offload, so the Intel
iGPU is what actually composites — but the dGPU is what the machine is
*specified* as having, which is the question this pane answers. On a machine
with no NVIDIA card it falls back to whichever card is listed first rather than
leaving the row blank.

Header and pane overlap on OS, kernel and uptime — the header carries them
because it is above the rail and does not change when the pane does.

Two things are deliberately **not** in it:

- **No `du`, anywhere.** The storage pane is `df` and `lsblk` only. `~/archive`
  is 1.9T and walking it would hold the panel open for minutes.
- **The network pane does not re-derive SSID, signal, latency or address.**
  Those are already live in the strip and are drawn from there, so the pane
  cannot disagree with the bars it sits under.

`fastfetch`'s own `shell` module is left out: it reports the shell that spawned
the probe, not the one you use.

The audio pane reads `wpctl`, not `pactl` — this host runs PipeWire natively
and `pactl` only exists when pipewire-pulse puts it there. It flags a sample
rate that is not 44100, which is the same condition that makes the konaste
script spawn a loopback sink.

### A reload leaves the panel blank if you let it

`menuOpen` and `menuPane` are plain values and survive a hot reload; `paneRows`
does not. Restoring a property to the value it already had emits no change
signal, so neither `onMenuOpenChanged` nor `onMenuPaneChanged` fires, and the
panel comes back with its rail and its chips drawn and nothing between them
until you click another pane and back. `Component.onCompleted` re-probes when
the panel is already open, which is the case that hits.

A pane that returns no rows at all draws `no readings` rather than a gap —
an empty pane and a broken one should not look the same.

### Hovering the rail is selecting it

Moving onto System, Network, Audio, Display or Storage switches to that pane.
No click, so reading down the rail does not cost five of them. `loadPane`
already coalesces — a probe in flight parks the next request and only the last
one asked for runs — so sweeping the whole rail spawns one probe for the pane
you stop on, not five. A click still works, for taps and so the row does not
feel dead.

Because hover *is* selection there is no separate hover state to draw: the
pane on the right is what tells you where you are. The rail's current row keeps
a faint block so the name you left the pointer on stays findable.

### Nothing fills, and there are no rules

No accent on hover anywhere, and neither menu title inverts while its menu is
down — the menu being on screen already says it, and a slab of accent under the
name said it twice in the loudest colour the strip owns. The name and the
address just brighten to white while their menu is open.

Green is now reserved for the things it reports on: the signal bars, the
address menu's link colour, and the logo. It is not interaction chrome.

Every separator rule is gone too — between the rail and the pane, under the
header, above the footer, and in the address menu. Spacing does the separating.

### Two things that do not work the obvious way

**`HyprlandFocusGrab` cannot dismiss it.** Arming the grab emits `cleared` on
the same frame: the grab wants a surface that already holds focus, and the
property that would grant focus is the one the grab is gating. The menu opened
and shut instantly. Dismissal is the mask instead — the strip's window is
`barHeight + 420` tall and normally masks input to the top 26px, so it is
click-through; while the menu is down the mask covers the whole band, and a
click anywhere beside or below the menu closes it. A click on a window further
down the screen does not.

**The layer surface never resizes.** It is always `barHeight + 420` and always
reserves only `barHeight`. Growing a layer surface to open a menu flickers, so
the menu is drawn into space that was already there and masked off. The
constant itself grew from 340 when the flat list became a panel — that is
fine; what stays banned is growing it *at runtime* to fit whatever is open,
which means the number has to clear the tallest pane (System, 13 rows), not
the one on screen.

`Quickshell.execDetached` takes a list despite the `qmltypes` declaring
`QString` — verified by running it, not by reading the file.

## Workspace dots

A row of ten dots beside the name, one per workspace, matching the
`for i = 1, 10` bind loop in `config/hypr/hyprland.lua`. They appear on a
workspace switch, hold for `dotsMs` (2s), then fade over `dotsFade` (450ms).

They are a confirmation, not a readout — they answer "which one did I just
land on", and that question expires. A permanent row of dots on a strip this
thin is a row of dots you stop seeing.

Each strip watches **its own** monitor's active workspace, so moving around on
the ultrawide does not flash the laptop's dots. Active is a 16px pill in the
accent; occupied is a 6px dot at `fgDim`; empty is the same dot at `fgFaint`.

Occupancy is presence in `Hyprland.workspaces.values` — Hyprland drops a
workspace from that list the moment its last window leaves, so being in the
model *is* the occupancy test. The special workspace shows up there as `-98`
and is ignored, since only ids 1–10 are drawn.

`visible` follows `opacity`, not `dotsShown`, so the fade is allowed to finish
before the row stops being drawn.

## The logo

The system pane carries the NixOS logo, in `logo.txt` beside `shell.qml` and
read through a `FileView`. A file rather than a QML string so it can be
swapped without escaping a wall of block glyphs. Regenerate with:

    fastfetch --logo NixOS -s " " --pipe | sed 's/\x1b\[[0-9;]*m//g' > logo.txt

**It has to be the block-element logo**, not `NixOS_small`. The small variant
draws with Legacy Computing sextants at U+1FB00, and JetBrainsMono Nerd Font
does not carry that range on this machine — `fc-list ':charset=1FB38'` returns
IosevkaTerm and nothing else — so it renders as a column of tofu. The full
`NixOS` logo is U+2580–259F block elements, which JetBrainsMono does have.

**Do not size the container from `logoBlock.implicitHeight`.** The logo is
anchored into the very container whose height it would feed, and reading its
implicit size from there is a binding loop: Qt resolves the anchors, that sets
the implicit size, that resizes the parent, which moves the anchors. `logoLines`
and `logoHeight` derive the height from the text and the font size instead.

It is 20 lines and 43 columns, drawn at `logoSize` (8px) and dimmed to 0.5:
it is decoration next to the readings, and at full accent it out-shouts every
one of them. `logoWidth` (214) is the inset the readings take to make room —
change `logoSize` and that has to follow, or the rows run under the widest
line.

## Why the network code is a shell script

`Quickshell.Networking` exists in 0.3.1 and exposes exactly what this needs —
`WifiNetwork.signalStrength`, `NetworkDevice.address`. It is unusable here: it
is a NetworkManager client, and this host runs **iwd**
(`nix/nixos/net/core.nix` sets `networking.networkmanager.enable = false`).

So `netstat.sh` reads iwd over D-Bus and prints one tab-separated line:

    bars  rssi  ip  flag  label

iwd has no RSSI property. `net.connman.iwd.Station` exposes `State`,
`ConnectedNetwork` and `ConnectedAccessPoint`, and nothing carrying signal.
The two read paths are:

- **`RegisterSignalLevelAgent`** — iwd pushes threshold crossings to an object
  you export on the bus. Correct and event-driven, and impossible from a shell
  script, which cannot export a D-Bus object.
- **`GetOrderedNetworks`** — returns `a(on)`, every visible network with its
  signal in dBm×100. Cached scan results, so calling it is a round trip and not
  a scan.

`netstat.sh` uses the second, on a 5s timer. It matches entries against
`ConnectedNetwork` rather than taking the first: the list is ordered by signal,
and the strongest *visible* network is frequently not the one you are joined
to — here `Sin Servicio` beats `Sin Servicio 5G` by 8 dBm while the link is on
the 5G one.

SSIDs arrive hex-encoded in the object path (`53696e...5347_psk`), which is
also how they survive spaces, parens and UTF-8 — `Astronomía 5g` round-trips.

`iwctl station wlan0 show` has the same numbers and needs no D-Bus parsing, but
it colours its output with ANSI escapes and lays it out as a fixed-width table,
so the SSID column cannot be split on whitespace.

`/proc/net/wireless` is empty on this machine — it is the old WEXT interface,
and nothing populates it under iwd. `iw` is not installed.

## Bar colour: signal *and* latency

Bar count is RSSI alone — that is what bars have always meant. Colour is the
worse of two readings, because neither one alone is "is this link any good":

| RSSI | bars |
| --- | --- |
| ≥ -50 | 4 |
| ≥ -60 | 3 |
| ≥ -70 | 2 |
| ≥ -80 | 1 |
| below | 0 |

| | green | yellow | red |
| --- | --- | --- | --- |
| bars | 3–4 | 2 | 0–1 |
| latency | ≤ 60ms | ≤ 200ms | > 200ms, or no reply |

Whichever is worse wins, so four bars with a 300ms path is red and two bars at
4ms is yellow. `bars = -1` means no wireless link at all, which is **not** the
same as offline: an ethernet route with the radio down is normal, the bars go
grey, and `label` carries the interface name instead of an SSID.

Throughput is the reading you actually want and the one that cannot be had
passively — measuring it means generating traffic, which a status bar has no
business doing every few seconds. Latency is the cheap proxy that catches what
RSSI structurally cannot: a full-strength association to an access point whose
own uplink is dead still reads as four bars.

`latency.sh` pings 1.1.1.1 once, on a 15s timer — slower than the 5s RSSI poll,
because RSSI is a property read and this is a packet on the wire. It pings
1.1.1.1 rather than the default gateway because with a tunnel up the gateway
*is* the tunnel endpoint, which answers whether or not anything past it works.
`-1` means no reply, and is always red.

Thresholds are `latOk` / `latBad` at the top of `shell.qml`.

## The address menu

Clicking the bars or the address opens a menu listing every IPv4 address on the
machine, default route first, then tunnels, then the rest. Clicking a row copies
that address. The footer carries the two numbers the bars are made of — RSSI and
latency — each coloured on its own scale, so a yellow bar can be traced to which
half caused it.

`addrs.sh` builds it from `ip -br -4 addr`, tagging the interface that carries
the default route. It runs only when the menu opens.

Only one menu is down at a time, and each closes the other — `onMenuOpenChanged`
and `onIpMenuOpenChanged` do it, and each signal has exactly **one** handler
because QML silently keeps only the last if you write two.

## The address is the tunnel address

`ip` is the source address of the default route, so with Mullvad up it is
`10.135.x.x`, not the LAN `192.168.1.84`. That is deliberate — it is the
address anything outside this machine sees. The `vpn` tag marks it; the tag's
*absence* is the state worth noticing, which is why the bare case draws nothing
rather than a `lan` label.

For the LAN address instead, change the `ip -4 route get` line in `netstat.sh`
to `hostname -I | cut -d' ' -f1`.

## Knobs

All at the top of `shell.qml`:

- `accent` / `warn` / `crit` — the three bar colours. `#8a5cd6` matches the
  Hyprland active border if the green is too much.
- `latOk` / `latBad` — 60 and 200 ms, the yellow and red latency thresholds.
- `dotsMs` / `dotsFade` / `wsCount` — 2000 ms, 450 ms, 10. `wsCount` must match
  the bind loop in `config/hypr/hyprland.lua`.
- `logoWidth` / `logoSize` — 214 and 8; they move together.
- `pollMs` — 5000. The timer skips its tick while a probe is still running, so
  a hung `busctl` cannot pile up processes. The latency timer is fixed at 15s.
- `menuWidth` / `railWidth` / `keyWidth` — 704, 132 and 140. The panel is a
  fixed width and both columns of every row elide into it: a pane is not
  allowed to resize the panel, or switching panes would make it twitch.
  `keyWidth` is set by the longest key fastfetch emits, which is the battery's
  model number.
- `barHeight` — 26, and the exclusive zone follows it.
- `hideOnFullscreen` — the strip hides per-monitor on a fullscreen workspace,
  so a game on the ultrawide does not blank the laptop's copy.

Quickshell 0.3.1 ships no type carrying the hostname, so `shell.qml` reads
`/proc/sys/kernel/hostname` through a `FileView` with `blockLoading`.

Parse probe output with an explicit `isNaN` check, never `parseInt(x) || -1` —
a sub-millisecond ping parses to `0`, which is falsy, and rendered a perfect
link as unreachable.

## Implementation notes

`config/quickshell/bar/` carries no comments; this is what was in them.

**Run and toggle.** `qs -c bar`, and `qs -c bar ipc call bar toggle` (bound in
`config/hypr/hyprland.lua`). The IPC handlers also force a re-read without
waiting for the timer, print what the strip currently believes for debugging
without a screenshot, and switch the menu's pane by the `id` fields in
`menuPanes`. A toggle from a shell has no screen in the event, so it falls back
to whichever monitor has focus.

**Network state comes from `netstat.sh`, which reads iwd over D-Bus.** There is
no `Quickshell.Networking` here on purpose: that module is a NetworkManager
client and this host runs iwd. `bars = -1` means "no wifi link", which is not
the same as offline — an ethernet route with no radio is a normal state. The
poll is a D-Bus round trip and two property reads, since iwd caches scan
results: cheap, not free. The latency probe is deliberately slower, because it
puts a packet on the wire, and it skips a tick while the previous one is still
running so a hung `busctl` cannot pile up processes. Parsing uses an explicit
null check rather than `|| -1`: a sub-millisecond reply parses to `0`, which is
falsy, and would render a perfect link as unreachable. Green needs the radio
*and* the path to both be good — signal strength alone cannot see a dead uplink,
and a ping alone cannot see a link about to drop — so the worse of the two wins.

**Hostname is read from procfs**, because Quickshell 0.3.1 ships no type
carrying it, with `blockLoading` since it is wanted for the very first paint and
it is a few bytes on a pseudo-filesystem.

**The logo is a file, not a QML string,** so it can be swapped without touching
code or escaping a wall of block glyphs. Regenerate with:

```bash
fastfetch --logo NixOS -s " " --pipe | sed 's/\x1b\[[0-9;]*m//g' > logo.txt
```

It must be block elements (U+2580–259F). fastfetch's `NixOS_small` uses the
Legacy Computing sextants at U+1FB00, which JetBrainsMono Nerd Font does not
carry on this machine — only IosevkaTerm does — so it renders as a column of
tofu. The logo column is sized as 43 columns at `logoSize` plus a gutter;
change the size and that has to follow, or the rows run under its widest line.
Its line count and height are derived from the text rather than read back off
the rendered item: the logo is anchored into the container whose height this
feeds, and asking the item for its `implicitHeight` from there is a binding loop
— Qt resolves anchors, that sets the implicit size, that resizes the parent,
which moves the anchors.

**The menu panes.** `paneRows` is kept per pane rather than as one list, so
switching back to a pane you have already opened paints immediately instead of
blanking for the length of a process spawn. Every pane is a sub-100ms probe
(measured), so there is no spinner — the previous rows stay up and are replaced
in one frame. Clicking down the rail faster than the probes return would drop
every click but the first, so the last one asked for wins. Rows are replaced
with a fresh object because QML watches the reference: mutating the existing map
in place updates nothing on screen. A hot reload keeps `menuOpen` and `menuPane`
— they are plain values — but drops `paneRows`, and restoring a property to the
value it already had emits nothing, so an explicit re-probe is needed or the
menu comes back with its rail and chips drawn and no readings between them. Add
a pane by appending to the model and adding a matching case to `sysinfo.sh`;
nothing else knows how many there are. Each menu closes the other with one
handler per signal, since QML takes only the last otherwise.

**The surface.** The window is tall enough to hold the menu and masked below the
strip. Resizing a layer surface to open a menu flickers, so it does not resize —
which means the height has to fit the tallest pane (system, 12 rows) rather than
whichever menu is open. It gets its own namespace so the blur rule in
`hyprland.lua` can skip it; that rule is anchored to `^quickshell$` and now
covers only hyprquickpaper, while the hyprglass exclusion still matches on the
prefix. Keyboard focus is needed for the menu to take clicks at all — layer
surfaces are click-through to the compositor without it. Closed, only the strip
takes input; open, the whole surface does, so a click beside the menu dismisses
it.

**No `HyprlandFocusGrab`.** It fires `cleared` the instant it is activated: the
grab wants a surface that already holds focus, and the menu's own focus is what
would grant it, so arming it closes the menu on the same frame it opened. The
full-width mask is the dismiss surface instead — anywhere in the strip's 340px
band, beside or below the menu, closes it.

**Per screen.** The menu belongs to the screen whose name was clicked; opening
it on the laptop must not paint it on the ultrawide. The dots follow *this*
screen's active workspace, not the focused one, so moving around on the
ultrawide does not flash the laptop's dots. `visible` follows opacity rather
than the shown flag so the fade is allowed to finish before the row stops being
drawn. The dot count is one per `for i = 1, 10` in `hyprland.lua` — change both
together. Occupancy needs no separate flag: Hyprland drops a workspace the
moment its last window leaves, so presence in the list *is* the test, and under
a compositor that reports none every inactive dot simply stays dim.

**Battery.** UPower's display device is the aggregate one — the laptop pack,
already merged if the machine has two — and `isLaptopBattery` keeps a bluetooth
mouse from ever appearing there. The strip reads "on AC", not "charging": a pack
sitting full on the charger is not charging but is just as plugged in. It pulses
only while actually filling, with `alwaysRunToEnd` so unplugging cannot strand
the fade mid-cycle. The whole group is hidden on a machine with no pack, so a
desktop shows nothing rather than an empty gauge.

