# Bar surface: tint, blur, and the bottom edge

Three settings decide how the bar sits against the desktop. They are coupled —
changing one without the others breaks the look.

## Tint — `bg` in `shell.qml`

`#870d0d12`: alpha `0x87` (~53%) over ghostty's background colour `#0d0d12`.

**This pairing is currently broken and the bar is the heavier half.** Ghostty
ran `background-opacity = 0.48` over the same `#0d0d12`, so bar and terminals
tinted the same blur with the same colour. Ghostty is now at `0` — it paints no
background, and its share of the tinting moved to hyprglass `tint_color`
(`#0d0d12` at 0.40, the same hex). The bar still paints its own `0x87`, so it
reads as a heavier slab than the terminals rather than the same material one
step up. Dropping the bar's alpha toward `0x66` would restore the match, but
that drags `ignore_alpha` with it — see below.

## Blur — the `quickshell:bar` layer rule in `../../hypr/hyprland.lua`

Blur must stay on. Unblurred, the bar transmits sharp wallpaper: measured
against a wallpaper with hard architectural edges, brightness swung 3.1x across
the bar's own width (luminance 7.7 to 23.7) and the wallpaper's diagonals cut
visibly through the workspace dots. A tint only reads as a surface when what it
tints is already flat.

`ignore_alpha = 0.5` is the lever that keeps the shadow band (below) from
blurring the windows underneath it. Hyprland skips blur behind pixels whose
alpha falls under this threshold, so the value must sit just below `bg`'s alpha:
the bar proper (0.53) blurs, everything in the falloff does not.

**This means `bg`'s alpha can never drop below 0.5 without also lowering
`ignore_alpha`** — otherwise the bar silently stops blurring altogether.

## Bottom edge — `shadowHeight` and the gradient in `shell.qml`

The window is `barHeight + shadowHeight` tall while `exclusiveZone` stays at
`barHeight`, so tiled windows still start at y=34 and the extra 14px hang over
them as a drop shadow rather than displacing anything.

The gradient's stops fall off on a curve (1.0, 0.68, 0.44, 0.21, 0.085, 0)
rather than linearly, which is what makes it read as a shadow instead of a
ramp. Stops are derived from `bg` via `Qt.rgba`, so retinting the bar retints
the falloff with it.

`mask` restricts the input region to the top `barHeight`. Without it the
shadow band would swallow clicks meant for the window below.
