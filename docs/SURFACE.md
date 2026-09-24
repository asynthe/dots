# Bar surface: black, blur, and the bottom edge

How the bar sits against the desktop. All three settings below used to be
coupled — a tint that had to match ghostty, a blur that had to stay on to flatten
what the tint sat over, and an `ignore_alpha` threshold pinned just under the
tint's alpha. **Going opaque decoupled them.** This page is mostly a record of
why there is nothing left to balance.

## Black — `bg` in `../config/quickshell/bar/shell.qml`

`#000000`, fully opaque. OLED black: the panel emits no light along the top edge.

It was `#cc0d0d12` — ghostty's background at 80% — and before that `#870d0d12`
at ~53%, chosen so the bar and the terminals tinted the same blur with the same
colour. That pairing had already drifted: ghostty moved to
`background-opacity = 0` and handed its share of the tinting to hyprglass
`tint_color`, while the bar kept painting its own alpha and read as the heavier
slab. Opaque ends the matching problem instead of re-tuning it — the strip is
its own surface now, not a layer of the same material.

`bg` is read in exactly one place, the strip's backing rectangle. Nothing else
derives from it.

## Blur — the `^quickshell$` layer rule in `../config/hypr/hyprland.lua`

**The bar is not blurred, and must not be.** Nothing shows through an opaque
surface, so blurring behind it is GPU spent on an invisible result.

This mattered when the bar was translucent: unblurred, it transmitted sharp
wallpaper, and measured against one with hard architectural edges the brightness
swung 3.1x across the bar's own width (luminance 7.7 to 23.7), with the
wallpaper's diagonals cutting visibly through the widgets. A tint only reads as
a surface when what it tints is already flat. Black is flat by itself.

The rule is still there, because the namespace is shared. `hyprquickpaper` sets
no namespace of its own and so defaults to `quickshell`, and its root really is
transparent — it needs the blur. So the rule is anchored to `^quickshell$`,
which reaches the picker and not the bar, and the bar declares
`WlrLayershell.namespace: "quickshell:bar"` to stay out of it.

`ignore_alpha = 0.5` survives for the same reason: it is the picker's threshold
now, not the bar's. Hyprland skips blur behind pixels whose alpha falls under it.

The hyprglass exclusion, `hg.layer("quickshell", { exclude = true })`, matches on
the prefix and so still covers `quickshell:bar`. It is a no-op while hyprglass
layers are off regardless.

## Bottom edge — there isn't one

The bar ends at `barHeight` with a hard edge. No drop shadow, no gradient
falloff, no `shadowHeight`, and no `mask` to keep a shadow band from swallowing
clicks — the window is exactly as tall as the bar, so its whole surface is the
bar.

The old translucent bar faded out over 14px below itself on a curve (1.0, 0.68,
0.44, 0.21, 0.085, 0) so the edge read as a shadow rather than a ramp, with the
window `barHeight + shadowHeight` tall while `exclusiveZone` stayed at
`barHeight` so tiled windows were not displaced by it. Against black the falloff
had nothing to soften, so it went.

The window is still taller than the strip — `barHeight + 420` — but that is the
name menu's room, and `mask` tracks whether a menu is open rather than covering
a fixed band.
