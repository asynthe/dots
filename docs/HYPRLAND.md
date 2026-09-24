# `hyprland.lua`

The compositor config, in Lua. `hyprctl dispatch` therefore parses its argument
as Lua — see [../CLAUDE.md](../CLAUDE.md) for what that breaks. Glass tuning
lives in [HYPRGLASS.md](HYPRGLASS.md); this is everything else in the file, in
the order the file has it.

## Environment

Qt goes through the gtk3 platform theme, which reads `GTK_THEME` and hands Qt a
matching dark palette. No `QT_STYLE_OVERRIDE` — it only ever named the
adwaita-qt style, which is not installed here.

## Plugins

`hyprglass` is built by nix against this host's Hyprland and lands in the system
profile, so the path in the config is stable across rebuilds.

The plugin table is **false on the first parse**. Loading a plugin triggers a
config reload, and the table only exists on the second pass — which is why the
plugin block is guarded rather than written straight.

## Decoration

**Square corners cost the glass nothing.** The bezel is driven by the
*magnitude* of the box SDF, not its curvature, and a square box has a perfectly
good distance field. The bezel-width knob is `edge_thickness`, not `rounding`.
`rounding_power` is inert at `rounding = 0` — it only shapes the corner arc —
and is kept so raising rounding back to 14 restores the old look in one edit.

## Window rules

**Never dim:** `inactive_opacity` multiplies the whole surface, which video
players and wine apps repaint badly. `override` on all three slots pins active,
inactive and fullscreen alike.

**Steam games open fullscreen.** Games carry class `steam_app_<appid>`; the
client itself is plain `steam` and non-Steam apps never match, so only games are
hit. The bar hides itself on a fullscreen workspace — see [BAR.md](BAR.md).

**Glass exclusions are matched on class only.** A `fullscreen = true` match tags
once and never untags, so a window that was fullscreen once would lose its glass
for the rest of its life. XWayland is the one safe static match — it never
changes over a window's life — and it is excluded now only for XWayland's own
scaling and damage-tracking quirks, not for its square corners, which cost the
effect nothing. Drop that line if XWayland windows look fine with glass on.

`no_focus` on children keeps a window's children on the same workspace, which is
what makes Steam and its games behave.

## Layer rules

Blur is anchored rather than blanket: the bar is `quickshell:bar` and opaque, so
it wants none. What is left is `hyprquickpaper`, whose root is transparent and
does. See [SURFACE.md](SURFACE.md).

## Handles

Window and layer rules both return a handle, so a rule can be toggled at
runtime with `:set_enabled(false)` rather than edited out.
