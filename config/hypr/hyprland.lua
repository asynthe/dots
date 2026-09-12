-- ───────────────────────── Monitors ─────────────────────────
local monitors = require("monitors")


-- ───────────────────────── Autostart ─────────────────────────
hl.on("hyprland.start", function ()
    hl.exec_cmd("mpd")
    hl.exec_cmd("uwsm app -- mullvad-vpn")
    hl.exec_cmd("uwsm app -- nm-applet --indicator")
    --hl.exec_cmd("[workspace 9 silent] musicbee")
    hl.exec_cmd("[workspace 10 silent] webcord")

    -- services and daemons
    --hl.exec_cmd("elephant")
    --hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("systemctl --user enable --now hypridle.service")
    hl.exec_cmd("uwsm app -- awww-daemon")
    hl.exec_cmd("systemctl --user enable --now tide-island.service")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/wallpaper.sh")
    hl.exec_cmd("uwsm app -- " .. os.getenv("HOME") .. "/.config/hypr/cursor_shake.py")
end)


-- ───────────────────────── Environment ─────────────────────────
-- Cursor
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "26")
hl.env("XCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("XCURSOR_SIZE", "26")

-- Dark mode. Qt goes through the gtk3 platform theme, which reads GTK_THEME
-- and hands Qt a matching dark palette -- no QT_STYLE_OVERRIDE, which only ever
-- named the adwaita-qt style that is not installed here.
hl.env("GTK_THEME", "adw-gtk3-dark")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Wayland specific
hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Permissions
hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")


-- ───────────────────────── Plugins ─────────────────────────
-- hyprglass: liquid-glass decorations behind transparent surfaces. Nix builds
-- it against this host's Hyprland and puts it in the system profile, so the
-- path is stable across rebuilds. See docs/HYPRGLASS.md.
local hyprglass = "/run/current-system/sw/lib/libhyprglass.so"
hl.permission(hyprglass, "plugin", "allow")
hl.plugin.load(hyprglass)

-- False on the first parse. Loading a plugin triggers a config reload, and the
-- table exists on the second pass.
if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    -- "#RRGGBB" + alpha -> the packed RRGGBBAA int the plugin wants, so tints
    -- can be written as the same hex the island and ghostty use.
    local function tint(c, alpha)
        return tonumber(c:match("%x%x%x%x%x%x"), 16) * 256
             + math.floor(alpha * 255 + 0.5)
    end

    -- The three presets below are the reference config verbatim.
    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 1.0,
        dark  = { brightness = 0.82 },
        light = { brightness = 1.2 },
    })

    hg.preset("contrasted", {
        inherits     = "high_contrast",
        contrast     = 1.2,
        adaptive_dim = 1.0,
        dark = { tint_color = 0x02142aa9 },    -- tint("#02142a", 0.663)
    })

    hg.preset("apple", {
        blur_strength        = 2.2,
        blur_iterations      = 3,
        refraction_strength  = 0.55,
        chromatic_aberration = 0.3,
        fresnel_strength     = 0.5,
        specular_strength    = 0.75,
        edge_thickness       = 0.05,
        lens_distortion      = 0.3,

        -- Both tables are the plugin's own per-theme defaults written out --
        -- inert as they stand, kept as the surface to tune from.
        dark  = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim   = 0.4 },
        light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
    })

    -- Same slab, pushed hard. Refraction only reads as distortion when there is
    -- high-frequency detail behind it to bend, so this widens the bezel and
    -- *lowers* the blur -- heavy blur destroys the very detail being displaced.
    hg.preset("apple_strong", {
        inherits             = "apple",
        blur_strength        = 1.4,
        blur_iterations      = 2,
        refraction_strength  = 0.9,
        chromatic_aberration = 0.7,
        lens_distortion      = 0.8,
        edge_thickness       = 0.12,

        -- The two pure-white terms, both added *after* the tint and both
        -- scaled by the bezel, which `edge_thickness` just widened. Cut low
        -- rather than to zero: the rim is what reads as an edge. See
        -- docs/HYPRGLASS.md.
        fresnel_strength     = 0.25,
        specular_strength    = 0.15,

        -- With `background-opacity = 0` there is no terminal background left,
        -- so readability is this line's job. `adaptive_dim` crushes bright
        -- areas and leaves dark ones alone, which is what keeps text legible
        -- over a pale wallpaper without flattening a dark one. A flat tint
        -- cannot do that -- it dims both equally.
        -- No brightness override: the old 1.16 existed to punch through
        -- ghostty's dark sheet and only washed the glass out once that went.
        -- `contrast` pivots on 0.5, so the inherited 0.90 lifted black toward
        -- grey across the whole slab; 1.0 is the neutral pivot. Saturation is
        -- a mix toward luminance grey -- 0.80 was the milky half of the haze.
        dark = { adaptive_dim = 0.85, contrast = 1.0, saturation = 0.9 },
    })

    -- No-op while layers are off, kept because the reference config excludes
    -- the shell layer too -- same conclusion.
    hg.layer("quickshell", { exclude = true })

    hg.config({
        default_theme  = "dark",
        default_preset = "apple_strong",

        -- Ghostty's background, so glass tints the same colour as the rest of
        -- the desktop. With `background-opacity = 0` this is the *only* thing
        -- darkening the terminal, so it carries the readability -- it was 0.13
        -- back when ghostty painted its own sheet on top. See docs/SURFACE.md.
        tint_color = tint("#0d0d12", 0.40),

        -- Off: layer glass hooks a private Hyprland internal, and it would
        -- replace the bar's own blur. See docs/HYPRGLASS.md.
        layers = { enabled = false },
    })

    -- Anything where the glass fights the content rather than framing it.
    -- Class only: a `fullscreen = true` match tags once and never untags, so a
    -- window that was fullscreen once would lose glass for the rest of its life.
    hl.window_rule({ match = { class = "^(mpv|imv|steam_app_[0-9]+)$" }, tag = "+hyprglass_disabled" })

    -- XWayland windows get no glass. They already opt out of `rounding` further
    -- down, and refraction is driven by the rounded-rect edge gradient, so with
    -- square corners the effect has nothing to bend and only costs a blur pass.
    -- Safe as a static match: `xwayland` never changes over a window's life, so
    -- the tag-once caveat above does not apply. See docs/HYPRGLASS.md.
    hl.window_rule({ match = { xwayland = true }, tag = "+hyprglass_disabled" })
end


-- ───────────────────────── Configuration ─────────────────────────
hl.config({
    general = {
        layout = "dwindle",
        border_size = 0,
        gaps_in  = 4,
        gaps_out = 14,
        col = {
            active_border = { colors = { "rgb(451F67)" }, },
            inactive_border = "rgb(000000)",
            -- Default
            --active_border = { 
            --colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, 
            --angle = 45 
            --},
            --inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false, -- TODO Enable when gaming, with a window_rule with `immediate` set to true
    },
    dwindle = {
        preserve_split = true,
        special_scale_factor = 0.92,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },

    -- Misc
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,

        -- This makes any windows children open on the same workspace (eg. Steam and games)
        initial_workspace_tracking = 0,

        -- Window swallowing
        --enable_swallow = true,
        --swallow_regex = "(Alacritty|com.mitchellh.ghostty|kitty|org.wezfurlong.wezterm)",
    },

    -- Decoration
    decoration = {
        -- Non-zero for hyprglass: refraction is driven by the edge gradient of
        -- the window's rounded-rect SDF, and square corners have none.
        rounding       = 14,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        -- Shadow
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        -- Blur
        blur = {
            enabled   = true,
            xray      = false,
            size      = 8,
            passes    = 3,
            vibrancy  = 0.1696,
        },

        -- Motion blur
        --motion_blur = {
        --    enabled = true,
        --},
    },
})

-- Input
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "ctrl:nocaps", -- switch caps lock for ctrl
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- per-device config
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Smart gaps
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

-- Ignore smart gaps in special workspaces
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })

-- XWayland
hl.config({ xwayland = { force_zero_scaling = true }, })
hl.window_rule({ -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-dragging",
    no_focus = true,
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
})


-- ───────────────────────── Animations ─────────────────────────
hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("default",  { type = "bezier", points = { { 0,    1     }, { 0,     1 } } })
hl.curve("wind",     { type = "bezier", points = { { 0.05, 0.618 }, { 0.1,   1 } } })
hl.curve("winIn",    { type = "bezier", points = { { 0.1,  1.1   }, { 0.1,   1 } } })
hl.curve("winOut",   { type = "bezier", points = { { 0.3,  1     }, { 0,     1 } } })
hl.curve("linear",   { type = "bezier", points = { { 1,    1     }, { 1,     1 } } })
hl.curve("ease",     { type = "bezier", points = { { 0,    1     }, { 0.618, 1 } } })

hl.animation({ leaf = "windowsIn",        enabled = true, speed = 2.427, bezier = "ease", style = "slide"     })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 2.427, bezier = "ease", style = "slide"     })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 2.427, bezier = "ease", style = "slide"     })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 2.427, bezier = "ease", style = "slide"     })
hl.animation({ leaf = "layers",           enabled = true, speed = 2.427, bezier = "ease", style = "fade"      })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.427, bezier = "ease", style = "fade"      })
hl.animation({ leaf = "fadePopups",       enabled = true, speed = 2.427, bezier = "ease"                      })

-- ───────────────────────── Window Rules ─────────────────────────
hl.window_rule({ match = { xwayland = true }, rounding = 0 }) -- xwayland
-- Windows that must never dim. `inactive_opacity` multiplies the whole
-- surface, which video players and wine apps repaint badly. `override` on all
-- three slots pins active, inactive and fullscreen alike.
local noDimClasses = {
    "^(mpv|steam_app)(.*)$",
    "(?i)^.*\\.exe$",    -- wine: the window class is the exe name (MusicBee.exe, ...)
}

for _, class in ipairs(noDimClasses) do
    hl.window_rule({ match = { class = class }, opacity = "1 override 1 override 1 override" })
end

-- Steam games open fullscreen. Games are class `steam_app_<appid>`; the client
-- itself is plain `steam`, and non-Steam apps never match, so only games are hit.
-- The island gets out of the way on its own -- see docs/TIDE.md.
hl.window_rule({
    name       = "steam-games-fullscreen",
    match      = { class = "^steam_app_[0-9]+$" },
    fullscreen = true,
})
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, center = true, float = true, size = "1360 825" })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true, border_size = 0 })
hl.window_rule({ match = { title = "^(Media viewer)$" }, float = true })

-- Terminal
hl.window_rule({ 
    match = { 
        class = "^("
            .. "com.mitchellh.ghostty|" 
            .. "org.wezfurlong.wezterm" 
            .. ")(.*)$"
    }, 
    --border_size = 0,
    float = true, 
    size = "1360 825" 
})

hl.window_rule({
    match = {
        title = "^("
            .. "Input Error|"
            -- TODO Fix
            --.. "<vm> on QEMU/KVM|"
            .. "Add New Virtual Hardware|"
            .. "Locate ISO media volume|"
            .. "New VM"
            .. ")(.*)$"
    },
    border_size = 0,
    center = true,
})
hl.window_rule({
  match = {
    title = "^("
      .. "Choose wallpaper|"
      .. "Enter name of file to save to|"
      .. "Export Image as PNG|"
      .. "File Upload|"
      .. "Library|"
      .. "Open File|"
      .. "Open Folder|"
      .. "Save As|"
      .. "Select a File|"
      .. "Select ISO|"
      .. "Select Game Folder"
      .. ")(.*)$"
  },
  float       = true,
  center      = true,
  border_size = 0,
  size        = "1230 690",
})

-- Layer rules
hl.layer_rule({
    match = { namespace = "walker" },
    blur = true,
    dim_around = true,
    ignore_alpha = 1,
    animation = "slide",
})

hl.layer_rule({
    match = { namespace = "quickshell" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    match = { namespace = "logout_dialog" },
    blur = true,
    ignore_alpha = 0.5,
    dim_around = true,
})

-- Other
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})


-- ───────────────────────── Keybinds ─────────────────────────
local mainMod = "ALT"
local terminal    = "ghostty"
local fileManager = "thunar"
local menu        = "fuzzel"
local island      = "quickshell ipc --any-display -p " ..
                    os.getenv("HOME") .. "/.local/share/tide-island"
-- Auto-hide is runtime state inside the shell and cannot be read back, so the
-- marker file is what remembers which way the pin went. See docs/TIDE.md.
local islandPin   = 'p="${XDG_RUNTIME_DIR:-/tmp}/tide-pinned"; ' ..
                    'if [ -e "$p" ]; then rm -f "$p"; ' ..
                    island .. ' call island enableAutoHide; ' ..
                    'else : > "$p"; ' ..
                    island .. ' call island disableAutoHide; fi'
local screenshotsDir = (os.getenv("HOME") or "~") .. "/downloads/screenshots"

hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pkill pavucontrol || pavucontrol"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell kill -c hyprquickpaper || quickshell -c hyprquickpaper"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
-- Pin the island open, or hand it back to auto-hide. IPC rather than a global
-- shortcut so it keeps one toggle point that works from a shell too.
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(islandPin))
--hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("kanri"))
local closeWindowBind = hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Monitor
hl.bind(mainMod .. " + SHIFT + Z", monitors.toggle_laptop_screen)

-- Screenshot
hl.bind("Print",       hl.dsp.exec_cmd("hyprshot -m region -o "  .. screenshotsDir))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -o " .. screenshotsDir))
-- TODO gromit-mpx is cool
-- Drawing (with gromix-mpx)
-- NOTE done with tray in waybar for now, but would be interesting to set up something like this.
-- bind = $mainMod, w, exec, gromix-mpx -a
-- bind = $mainMod, d, submap, Draw mode (gromit-mpx)
-- submap = Draw mode (gromit-mpx)
--     bind = $mainMod, t, exec, gromit-mpx --toggle
--     bind = $mainMod, c, exec, gromit-mpx --clear
--     bind = $mainMod, v, exec, gromit-mpx --visibility
--     bind = $mainMod, ., exec, gromit-mpx --undo
--     #bind = SUPER, ,, exec, gromit-mpx --redo
--     bind = , escape, exec, gromix-mpx --quit
--     bind = , escape, submap, reset
-- submap = reset

-- Windows
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next({ repeating = true }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind(mainMod .. " + D", hl.dsp.layout("togglesplit"))    -- dwindle only
-- Hyprland skips *all* window decorations when the internal mode is
-- FSMODE_FULLSCREEN, and hyprglass is a decoration -- so true fullscreen has
-- no glass. Splitting the state keeps it: internal 1 (maximized) still
-- decorates, client 2 (fullscreen) still tells the app it is fullscreen.
-- Costs the island's exclusive zone. See docs/HYPRGLASS.md.
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 1, client = 2, action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())    -- dwindle only
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- focus, move, move floating, resize
local keys = {
    left  = { "h", "left",  "l" },
    right = { "l", "right", "r" },
    up    = { "k", "up",    "u" },
    down  = { "j", "down",  "d" },
}
local deltas = {
    left  = { x = -10, y = 0 },
    right = { x =  10, y = 0 },
    up    = { x = 0, y = -10 },
    down  = { x = 0, y =  10 },
}
for dir, v in pairs(keys) do
    local vim   = v[1]
    local arrow = v[2]
    local delta = deltas[dir]
    -- Bare mainMod + arrow is left to the focused app (ghostty scrollback); focus uses vim keys
    hl.bind(mainMod .. " + " .. vim,              hl.dsp.focus({ direction = dir }))
    for _, key in ipairs({ vim, arrow }) do
        hl.bind(mainMod .. " + CTRL + "  .. key,  hl.dsp.window.resize({ x = delta.x * 8, y = delta.y * 8, relative = true }), { repeating = true })
        hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ direction = dir }), { repeating = true })
        hl.bind(mainMod .. " + SUPER + " .. key,  hl.dsp.window.move({ x = delta.x * 5, y = delta.y * 5, relative = true }), { repeating = true })
    end
end

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + bracketleft", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + bracketright",   hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + comma",   hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.focus({ monitor = "r" }))

-- zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind(mainMod .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Misc: Zoom out" })
hl.bind(mainMod .. " + Equal", function() zoomfunction(0.3) end,  { repeating = true, description = "Misc: Zoom in" })
hl.bind(mainMod .. " + mouse_down", function() zoomfunction(-0.3) end, { repeating = true, description = "Misc: Zoom out" })
hl.bind(mainMod .. " + mouse_up", function() zoomfunction(0.3) end, { repeating = true, description = "Misc: Zoom in" })

-- Audio keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Brightnessctl
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Playerctl
--hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
--hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
--hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
--hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- TODO Laptop-specific (from old file)
-- Disable touchpad
-- from https://www.reddit.com/r/hyprland/comments/1bo6rp8/comment/kwo1qw1/
-- TODO Looking for the `hyprctl getoption enabled` for the touchpad, then put in just one keybind
-- bind = $mainMod SHIFT, RETURN, exec, hyprctl getoption "device:synps/2-synaptics-touchpad:enabled" | grep 'int: 1' && (hyprctl keyword "device:synps/2-synaptics-touchpad:enabled" false && notify-send "Trackpad disabled") || (hyprctl keyword "device:synps/2-synaptics-touchpad:enabled" true)
-- bind = $mainMod SHIFT, b, exec, hyprctl keyword -r -- "device[elan0305:00-04f3:31fd-touchpad]:enabled" "true" && notify-send "[!] Trackpad enabled"
-- bind = $mainMod SHIFT, n, exec, hyprctl keyword -r -- "device[elan0305:00-04f3:31fd-touchpad]:enabled" "false" && notify-send "[!] Trackpad disabled"
