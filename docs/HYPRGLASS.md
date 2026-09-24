# `hyprglass` aspect

[hyprglass](https://github.com/hyprnux/hyprglass) draws a liquid-glass slab
*behind* every window: frosted blur, edge refraction, chromatic fringing,
specular highlight. It only shows through transparency — an opaque window hides
its own glass completely.

Two halves: the `hyprglass` aspect in `../nix/nixos/desktop/hyprland.nix` builds
and installs the plugin, and the *Plugins* block in `../config/hypr/hyprland.lua`
loads and configures it.

## Why not hyprpm

Upstream recommends `hyprpm add`, which clones the repo, compiles it into
`~/.local/share/hyprland`, and expects to find Hyprland's headers on the system.
None of that survives a NixOS rebuild, and the store has no ambient toolchain
for it to use.

Instead the aspect wraps the source in `pkgs.hyprlandPlugins.mkHyprlandPlugin`,
passing `hyprland = config.programs.hyprland.package` so the plugin compiles
against the exact compositor this host runs. That matters: hyprglass compares
its build-time ABI signature against the running Hyprland and refuses to load on
a mismatch. Building from the same package makes a mismatch impossible, and it
keeps working if `hyprland-flake` is ever imported alongside `hyprland`.

`hyprpm.toml` upstream pins each hyprglass release to a Hyprland release. The
version in the aspect is chosen the same way — check that table when bumping
either side.

## The load path

`environment.systemPackages` links `lib/` into the system profile, so the plugin
lands at a path that does not change between rebuilds:

    /run/current-system/sw/lib/libhyprglass.so

That is what makes a hand-written `hyprland.lua` able to name it. The store path
underneath changes on every rebuild; the symlink does not, so Hyprland sees the
same string and never reloads the plugin on its own — a fresh build needs a
relogin (or `hyprctl plugin unload` / `load`) to take effect.

`ecosystem.enforce_permissions` is on, and a config-loaded plugin with no
matching rule pops a confirmation dialog every session, so the block also
carries its own `hl.permission(..., "plugin", "allow")`.

## The reload dance

`hl.plugin.hyprglass` does not exist while the config that loads the plugin is
being parsed. Hyprland registers the plugin, loads it, notices the plugin set
changed, and reparses — the table appears on that second pass. Hence the
`if hl.plugin.hyprglass then` guard: the first pass silently skips the
configuration, the second applies it. A `hg.config` call outside the guard is a
parse error on a cold start.

## What is actually glassed

Ghostty runs `background-opacity = 0.48`, so terminals are where the effect
lives. Firefox, Thunar and the rest are opaque and will look unchanged —
that is the plugin working correctly, not a misconfiguration.

`mpv`, `imv`, Steam games and anything fullscreen are tagged
`+hyprglass_disabled` — glass behind video is a blurred smear of the frame
before it.

Per-window overrides are tags, so they work live too:

```bash
hyprctl dispatch tagwindow +hyprglass_disabled
hyprctl dispatch tagwindow +hyprglass_preset_high_contrast
```

Built-in presets: `high_contrast`, `subtle`, `clear`, `glass`.

## Rounding is independent of the bezel

`decoration.rounding` is 0 — square corners — and the glass edge survives it.
This section previously claimed the opposite. It was wrong, and the error is
worth recording because it is the intuitive reading of the shader.

The bezel comes from `edgeProximity = exp(cornerSdf / (edge_thickness *
min(w, h)))` (`src/Shaders.hpp`). That reads the *magnitude* of the signed
distance field, not its gradient or curvature. At `radius = 0`,
`getRoundedBoxSDF` reduces to `max(q.x, q.y)` — the exact negative distance to
the nearest edge, smooth and well-defined across the whole window. Sampled at
`edge_thickness = 0.12` on an 800x800 window, `edgeProximity` is identical at
`radius` 0 and 14 at every point except the corner pixel itself, which at 14 is
outside the window and discarded anyway.

The refraction *direction* never touches the SDF either:

```
// Pixel-space direction toward window center — perfectly smooth everywhere,
// no SDF gradient needed.
vec2 refractionDir(vec2 uv) { ... }
```

So `refraction_strength`, `chromatic_aberration`, `fresnel_strength`,
`specular_strength` and the inner shadow all behave the same at 0. Only the
shape of the iso-contour changes: at 14 the band curves around the corner arc,
at 0 the two edge bands meet in a square L.

The old claim probably described an earlier build — the changelog has "attempt
with glass shader using SDF bezel refraction" and later "split corner/bezel
SDF ... to avoid weird corners", which is the gradient-based approach that got
replaced by the toward-centre one.

**The bezel-width knob is `edge_thickness`, not `rounding`.** `apple_strong`
runs 0.12, a bezel of `0.12 * min(w, h)`. Widen that, or raise
`refraction_strength` / `chromatic_aberration`, to make the edge read harder.
`rounding_power` is inert at `rounding = 0`; it only shapes the corner arc.

## The presets

Transcribed from screen captures of the author's `plugins.lua`, which is not
published. Between the frames the whole hyprglass half of that file was legible,
so `clear`, `contrasted` and `apple` are verbatim rather than reconstructed.

Two things in `apple` are worth knowing before tuning it:

- It sets **no** `tint_color` and **no** `glass_opacity`. The tint falls through
  to the global `hg.config`, and opacity stays at 1.0. Both are deliberate — the
  glass in the reference is a clear slab, and everything colouring it is global.
- Its `dark` and `light` tables are the plugin's documented per-theme defaults,
  written out longhand. As they stand they change nothing. They are kept because
  they are the surface you actually want to tune, spelled out and ready.

`tint()` is from the same file. It packs `"#RRGGBB"` plus an alpha float into
the `0xRRGGBBAA` integer the plugin wants, which is how the `contrasted` tint
was checked: `0x02142aa9` is `tint("#02142a", 0.663)`.

It earns its place here for a different reason — it lets the global tint be
written as ghostty's `#0d0d12` instead of a magic constant, so the colour stays
in step with [SURFACE.md](SURFACE.md).

**The alpha is tint strength, not surface opacity.** These are different numbers
that both happen to describe "how much colour". A surface opacity is how much
of its own background a window paints; a glass tint alpha is how hard the tint
is pushed into what shows through. The plugin defaults to `0x22`, so `0.13` here
sits in the same register — reaching for a surface-opacity figure like `0.53`
gives a murky slab nothing like the reference. (The bar itself is no longer in
this conversation at all: it is opaque `#000000` now. See
[SURFACE.md](SURFACE.md).)

## Where the white comes from

The shader's colour pipeline runs in a fixed order, and only four of its terms
add light. In order of how much haze they contribute to `apple_strong` on a dark
wallpaper:

```glsl
color = mix(vec3(0.5), color, contrast);   // 3. lifts black toward grey
color = mix(color, tintColor, tintAlpha);  // the tint -- everything below is after it
color += vec3(1.0) * edge^2 * fresnelStrength * 0.15;          // 1.
color += vec3(1.0, 0.99, 0.97) * top * edge^2 * spec * 0.08;   // 2.
```

**Fresnel and specular are added after the tint overlay.** Darkening
`tint_color` or raising its alpha cannot touch them — it only drops the field
they sit on, which makes the rim *more* obvious. They are the levers.

`edge` here is `exp(cornerSdf / (edge_thickness * min(w, h)))`, so the glow band
scales with `edge_thickness`. At `0.12` on an 825px-tall terminal that is a
~100px falloff — the "rim" covers a good fraction of the window. The bezel width
is doing double duty: it is what the refraction needs, and it is what spreads
the white.

`contrast` is the one term that whitens the *whole* slab rather than its edge.
It pivots on 0.5, so anything below 1.0 lifts black: at the plugin's dark
default of `0.90` that is a flat `+0.05` before the tint, `+0.03` after. 1.0 is
neutral; above 1.0 pushes darks down.

`saturation` does not lighten — it mixes toward luminance grey, which reads as
milky. It is the other half of what "washed out" usually means here.

Nothing above is geometry. Blur, refraction, chromatic aberration and lens
distortion are untouched by any of it, which is why the current numbers —
`fresnel 0.25`, `specular 0.15`, `contrast 1.0`, `saturation 0.9` — keep the
slab looking the same shape while cutting peak added white at the rim from
~0.18 to ~0.05.

### Tuning it

Preset fields outrank the global config in resolution, so
`hyprctl keyword plugin:hyprglass:fresnel_strength ...` is silently ignored
while `apple_strong` sets it. And the `preset` keyword rebuilds the whole preset
table from the built-ins plus whatever that one pass parsed, so poking a single
preset over hyprctl drops `apple` and breaks the inheritance chain.

Edit `hyprland.lua` and `hyprctl reload`. Only a new plugin *build* needs a
relogin.

## Alternate looks

`default_preset` picks the global one; tags override per window.

| Preset | What it is |
|---|---|
| `apple` | The reference look. Heavy blur, clear glass, soft edge. |
| `clear` | Author's override of the built-in — lighter blur, 0.8 opacity. |
| `contrasted` | Author's, off `high_contrast`. Cold blue tint, full `adaptive_dim`. |

Built-ins still available: `high_contrast`, `subtle`, `clear`, `glass`.

```bash
hyprctl dispatch tagwindow +hyprglass_preset_contrasted
```

## Layer surfaces are off

`layers.enabled = false`. Turning it on would mean:

```lua
hg.config({ layers = { enabled = true } })
hg.layer("quickshell:bar", { preset = "subtle", mask_threshold = 0.5 })
```

`mask_threshold` is the same lever as `ignore_alpha`. It mattered when the bar
was translucent and had a shadow falloff below it: 0.5 sat just under `bg`'s
0.53, so the bar proper was glassed and the falloff was not. The bar is opaque
black now with no falloff and is excluded from blur outright, so there is
nothing left for the threshold to separate — see [SURFACE.md](SURFACE.md).

The reference config reaches the same conclusion from the same starting point —
it runs quickshell under the same `quickshell:bar` namespace and excludes it
explicitly, `hg.layer("quickshell:bar", { exclude = true })`.

It stays off here for one further reason — and one that used to apply and no
longer does. Glass replaces blur, so a layer's `blur = true` has to come off
with it; that used to be disqualifying, because the bar's blur was what
flattened the wallpaper into something its tint could read against. An opaque
bar needs no blur, so that objection is gone. What remains: layer support hooks
`renderLayer`, a private Hyprland internal that
upstream warns may break on any Hyprland update; a broken hook takes the
compositor with it, not just the bar.

## Bumping the version

```bash
nix-prefetch-url --unpack https://github.com/hyprnux/hyprglass/archive/refs/tags/v<X.Y.Z>.tar.gz
nix hash convert --hash-algo sha256 --to sri <hash>
```

Then `version` and `hash` in the aspect, and relogin.

## Not transcribed

The captures cover lines 1-70 of a 99-line file. Unaccounted for:

- **Lines 71-99.** Since `hg.layer(...)` at line 70 excludes a namespace, the
  author almost certainly has `layers.enabled = true` further down, plus the
  global `hg.config` his `apple` preset leans on for its tint. If that file ever
  lands, the global block is the part worth diffing.
- **Lines 1-32 are `hyprbars`, not hyprglass** — a separate plugin drawing
  macOS-style titlebars, bound to `ALT + Y` behind a `hyprbars_enabled` flag, at
  `bar_height = 33` in `SF Pro Display`. It is a large part of why the reference
  reads as "Apple" and none of it is installed here. `pkgs.hyprlandPlugins.hyprbars`
  packages it; the font would need deciding first, since neither SF Pro nor a
  substitute is in the font aspect.

## Fullscreen kills the glass

hyprglass registers as a `DECORATION_LAYER_BOTTOM` decoration, and Hyprland
skips every window decoration in true fullscreen. One line in the renderer
decides it:

```cpp
// src/render/Renderer.cpp
renderdata.decorate = decorate && !pWindow->m_X11DoesntWantBorders
    && Fullscreen::controller()->getFullscreenModes(pWindow).internal != Fullscreen::FSMODE_FULLSCREEN;
```

Everything glass is drawn inside `if (renderdata.decorate)`, so there is no
plugin setting or config option that brings it back — the compositor never asks
the plugin to draw.

The condition tests the **internal** mode only, and Hyprland tracks internal and
client fullscreen separately (`FSMODE_NONE = 0`, `FSMODE_MAXIMIZED = 1`,
`FSMODE_FULLSCREEN = 2`). Splitting them is the way through:

```lua
hl.dsp.window.fullscreen_state({ internal = 1, client = 2, action = "toggle" })
```

Internal `1` keeps Hyprland decorating, so the glass survives; client `2` still
reports fullscreen over the protocol, so the application behaves as it would
fullscreen. `internal` and `client` are numbers here, not the `"maximized"` /
`"fullscreen"` strings that `hl.dsp.window.fullscreen` takes.

The cost is that maximized respects reserved space, so the bar's 34px exclusive
zone stays claimed and the window stops just short of the top edge. `ALT+SHIFT+B`
hides the bar, but the zone is reserved on map, not on visibility — hiding it
does not hand the strip back. For genuinely edge-to-edge, real fullscreen with
no glass is the only option.

## Tuning notes

The per-parameter reasoning behind the numbers in `hyprland.lua`, which carries
none of its own.

**`refraction_strength = 1.1`** — ×50 in the shader, so ~55px of inward UV
offset. Raised on measured headroom: the iGPU sits power-gated ~64% of the time
even while cycling a six-window glass workspace. Blur was left alone — it is low
on purpose, not for performance. Refraction only reads as distortion when there
is high-frequency detail behind it to bend, so the `apple_strong` preset widens
the bezel and *lowers* the blur: heavy blur destroys the very detail being
displaced.

**`chromatic_aberration`** is the only one of those that costs anything. Above
`0.001` it samples the blur three times in the bezel band instead of once.

**`edge_thickness = 0.18`** — bezel = `0.18 * min(w, h)`.

**`adaptive_dim = 0.55`.** With `background-opacity = 0` there is no terminal
background left, so readability is this line's job. `adaptive_dim` crushes
bright areas and leaves dark ones alone, which keeps text legible over a pale
wallpaper without flattening a dark one; a flat tint cannot do that, it dims
both equally. At `0.85` it did not just darken, it **inverted**: `lumCurve` is
`smoothstep(0.25, 0.55, lum)`, so a lum-0.55 region came out at 0.068 and a
lum-0.25 region at 0.205 — the brighter the wallpaper behind a patch of glass,
the darker that patch read. `0.55` keeps over half the pale-wallpaper guard and
restores the ordering.

**`brightness = 1.0`.** It multiplies with the above — `color *= brightness *
(1 - adaptive_dim * lumCurve)` — so `0.82 × 0.15` was an 88% cut on anything lit
before the tint took its 40%. `brightness` is flat and hits the dark end too,
where nothing threatens legibility; it was only ever the inherited default, not
a decision. 1.0 is the no-op, and not above it: the old 1.16 existed to punch
through ghostty's dark sheet and washes the glass out now that sheet is gone.

**`glass_opacity = 0.25`** over ghostty's background hex, so glass tints the
same colour as the rest of the desktop. With `background-opacity = 0` this is
the only thing darkening the terminal, so it carries the readability — it was
0.13 back when ghostty painted its own sheet. It is applied last in the tone
stage, after `adaptive_dim` has already taken its cut, so the two compound: at
0.40 over a near-black hex it was a quarter of the remaining light again. 0.25
holds the colour identity without being a second dimmer.

**`contrast = 1.0`, `saturation = 0.9`.** `contrast` pivots on 0.5, so the
inherited 0.90 lifted black toward grey across the whole slab. Saturation is a
mix toward luminance grey — 0.80 was the milky half of the haze.

The `apple` and `clear` preset tables are the plugin's own per-theme defaults
written out: inert as they stand, kept as the surface to tune from. `dark = {
tint_color = 0x02142aa9 }` is `tint("#02142a", 0.663)`.

The `hg.layer(...)` line for the shell namespace is a no-op while layers are
off. It is kept because the reference config excludes the shell layer too —
same conclusion, reached the same way.
