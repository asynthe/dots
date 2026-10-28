local monitors = require("monitors")

hl.on("hyprland.start", function()
    hl.exec_cmd("mpd")
    hl.exec_cmd("[workspace 1 silent] uwsm app -- mullvad-vpn")
    hl.exec_cmd("monerod --data-dir /home/meow/archive/monero --detach")
    hl.exec_cmd("[workspace 10 silent] vesktop")
    hl.exec_cmd("[workspace 1 silent] steam -silent")
    hl.exec_cmd("[workspace special:copilot silent] ghostty --class=com.mitchellh.ghostty.copilot -e hermes")

    hl.exec_cmd("systemctl --user enable --now hypridle.service")
    hl.exec_cmd("uwsm app -- awww-daemon")
    hl.exec_cmd("uwsm app -- qs -c bar")
    hl.exec_cmd("uwsm app -- qs -c desktop")
    hl.exec_cmd(os.getenv("HOME") .. "/git/dots/scripts/hypr/wallpaper.sh")
    hl.exec_cmd(os.getenv("HOME") .. "/git/dots/scripts/hypr/mpvpaper.sh")
    hl.exec_cmd("uwsm app -- " .. os.getenv("HOME") .. "/git/dots/scripts/hypr/cursor_shake.py")
    hl.exec_cmd(os.getenv("HOME") .. "/git/dots/scripts/hypr/focus-fix-daemon.py")
end)

hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "26")
hl.env("XCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("XCURSOR_SIZE", "26")

hl.env("GTK_THEME", "adw-gtk3-dark")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
-- Store hash changes every update, so match the hyprland path loosely.
hl.permission("(/nix/store/[a-z0-9]+-hyprland-[^/]+/bin|/usr/bin|/usr/local/bin)/(hyprctl|hyprpm)", "plugin", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")

-- NixOS installs into the system profile, Gentoo into /usr/local/lib.
local hyprglass
for _, p in ipairs({ "/run/current-system/sw/lib/libhyprglass.so", "/usr/local/lib/libhyprglass.so" }) do
    local f = io.open(p, "r")
    if f then
        f:close()
        hyprglass = p
        break
    end
end
hyprglass = hyprglass or "/usr/local/lib/libhyprglass.so"
hl.permission(hyprglass, "plugin", "allow")
hl.plugin.load(hyprglass)

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    local function tint(c, alpha)
        return tonumber(c:match("%x%x%x%x%x%x"), 16) * 256 + math.floor(alpha * 255 + 0.5)
    end

    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 1.0,
        dark = { brightness = 0.82 },
        light = { brightness = 1.2 },
    })

    hg.preset("contrasted", {
        inherits = "high_contrast",
        contrast = 1.2,
        adaptive_dim = 1.0,
        dark = { tint_color = 0x02142aa9 },
    })

    hg.preset("apple", {
        blur_strength = 2.2,
        blur_iterations = 3,
        refraction_strength = 0.55,
        chromatic_aberration = 0.3,
        fresnel_strength = 0.5,
        specular_strength = 0.75,
        edge_thickness = 0.05,
        lens_distortion = 0.3,

        dark = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
        light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
    })

    hg.preset("apple_strong", {
        inherits = "apple",
        blur_strength = 1.4,
        blur_iterations = 2,
        refraction_strength = 1.1, -- x50 -> 55px of inward UV offset
        chromatic_aberration = 0.85,
        lens_distortion = 0.8,
        edge_thickness = 0.18, -- bezel = 0.18 * min(w, h)

        fresnel_strength = 0.25,
        specular_strength = 0.15,

        dark = { brightness = 1.08, adaptive_dim = 0.35, contrast = 1.0, saturation = 0.9 },
    })

    hg.layer("quickshell:desktop", { exclude = true })

    hg.config({
        default_theme = "dark",
        default_preset = "apple_strong",

        tint_color = tint("#0d0d12", 0.15),

        layers = { enabled = true },
    })

    hl.window_rule({ match = { class = "^(mpv|imv|steam_app_[0-9]+)$" }, tag = "+hyprglass_disabled" })

    hl.window_rule({ match = { xwayland = true }, tag = "+hyprglass_disabled" })

    hl.window_rule({ match = { class = "(?i)^(steam|mullvad.*)$" }, tag = "+hyprglass_disabled" })
end

hl.config({
    general = {
        layout = "dwindle",
        border_size = 0,
        gaps_in = 4,
        gaps_out = 14,
        col = {
            active_border = { colors = { "rgb(451F67)" } },
            inactive_border = "rgb(000000)",
        },
        resize_on_border = true,
        extend_border_grab_area = 12,
        hover_icon_on_border = true,
        allow_tearing = false,
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

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        initial_workspace_tracking = 0,
    },

    decoration = {
        rounding = 0,

        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            xray = false,
            size = 8,
            passes = 3,
            vibrancy = 0.1696,
        },
    },
})

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "ctrl:nocaps", -- switch caps lock for ctrl
        kb_rules = "",
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
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- No float-by-default rule: it segfaults Hyprland with hyprglass loaded (notes: hyprland.md).

hl.window_rule({
    name = "musicbee-dialogs-float-no-center",
    match = { class = "^musicbee\\.exe$", title = "^(?!.* - MusicBee$).*$" },
    float = true,
})

hl.on("window.open", function(w)
    if w ~= nil and w.class == "explorer.exe" then
        hl.dispatch(hl.dsp.window.close({ window = "address:" .. w.address }))
    end
end)

hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })

hl.config({ xwayland = { force_zero_scaling = true } })
hl.window_rule({ -- Fix some dragging issues with XWayland
    name = "fix-xwayland-dragging",
    no_focus = true,
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("default", { type = "bezier", points = { { 0, 1 }, { 0, 1 } } })
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.618 }, { 0.1, 1 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, 1 }, { 0, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })
hl.curve("ease", { type = "bezier", points = { { 0, 1 }, { 0.618, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = false })
hl.animation({ leaf = "windowsOut", enabled = false })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.427, bezier = "ease" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.427, bezier = "ease" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.427, bezier = "ease", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.427, bezier = "ease", style = "slide" }) -- the desktop peek bind swaps this to a fade while it runs
hl.animation({ leaf = "layers", enabled = true, speed = 2.427, bezier = "ease", style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.427, bezier = "ease", style = "fade" })
hl.animation({ leaf = "fadePopups", enabled = true, speed = 2.427, bezier = "ease" })

hl.window_rule({ match = { xwayland = true }, rounding = 0 })

hl.window_rule({ -- Discord: tiled on its own workspace, overriding float-by-default
    name = "discord-tiled",
    match = { class = "^vesktop$" },
    workspace = "10 silent",
    float = false,
})
local noDimClasses = {
    "^(mpv|steam_app)(.*)$",
    "(?i)^.*\\.exe$", -- wine: the window class is the exe name (MusicBee.exe, ...)
}

for _, class in ipairs(noDimClasses) do
    hl.window_rule({ match = { class = class }, opacity = "1 override 1 override 1 override" })
end

hl.window_rule({
    name = "steam-games-fullscreen",
    match = { class = "^steam_app_[0-9]+$" },
    fullscreen = true,
})
hl.window_rule({ -- games just appear: Steam games and Wine (class is the exe name)
    name = "no-anim-games",
    match = { class = "(?i)^(steam_app_[0-9]+|.*\\.exe)$" },
    no_anim = true,
})
hl.window_rule({ -- Nucleus Co-op: override steam-games-fullscreen, its UI breaks fullscreen
    name = "nucleus-coop-float",
    match = { class = "^steam_app_2365297715$" },
    fullscreen = false,
    float = true,
    center = true,
})
hl.window_rule({ -- Steam and Mullvad just appear, no fade
    name = "no-anim-steam-mullvad",
    match = { class = "(?i)^(steam|mullvad.*)$" },
    no_anim = true,
})
hl.window_rule({ -- the Steam client (library, friends, dialogs) floats at its own sizes; games above stay fullscreen
    name = "steam-client-float",
    match = { class = "^[Ss]team$" },
    float = true,
    center = true,
})
hl.window_rule({ -- File Explorer opens as a window, not a tile
    name = "nemo-windowed",
    match = { class = "^nemo$" },
    float = true,
    size = "1100 680",
    center = true,
})
-- beatmania IIDX TDJ: main and touch sub windows pinned to native size.
local iidxTitle = "^beatmania IIDX [0-9]+ .* "
hl.window_rule({
    name = "iidx-main",
    match = { class = "^spice64\\.exe$", title = iidxTitle .. "main$" },
    float = true,
    size = "1920 1080",
    border_size = 0,
    rounding = 0,
})
hl.window_rule({
    name = "iidx-sub",
    match = { class = "^spice64\\.exe$", title = iidxTitle .. "sub$" },
    float = true,
    size = "1280 720",
    border_size = 0,
    rounding = 0,
})
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, center = true, float = true, size = "1360 825" })
hl.window_rule({
    name = "mullvad-bottom-right",
    match = { class = "(?i)^mullvad.*$" },
    float = true,
    size = "320 568",
    move = "monitor_w-340 monitor_h-588",
})
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true, border_size = 0 })
hl.window_rule({ match = { title = "^(Media viewer)$" }, float = true })

hl.window_rule({
    match = {
        class = "^(" .. "com.mitchellh.ghostty|" .. "org.wezfurlong.wezterm" .. ")(.*)$",
    },
    float = true,
    size = "1360 825",
})
-- By class: Hermes rewrites its window title to the session name.
hl.window_rule({ match = { class = "^com.mitchellh.ghostty\\.hermes$" }, move = "90 50" })

hl.window_rule({ match = { class = "^com.mitchellh.ghostty\\.copilot$" }, fullscreen = true })

hl.window_rule({
    match = {
        title = "^("
            .. "Input Error|"
            .. "Add New Virtual Hardware|"
            .. "Locate ISO media volume|"
            .. "New VM"
            .. ")(.*)$",
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
            .. ")(.*)$",
    },
    float = true,
    center = true,
    border_size = 0,
    size = "1230 690",
})

hl.layer_rule({
    match = { namespace = "walker" },
    blur = true,
    dim_around = true,
    ignore_alpha = 1,
    animation = "slide",
})

hl.layer_rule({
    match = { namespace = "launcher" },
    no_anim = true,
})

hl.layer_rule({
    match = { namespace = "^quickshell$" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    match = { namespace = "^quickshell:bar$" },
    blur = true,
    ignore_alpha = 0.3,
    no_anim = true, -- the surface grows 26px -> 446px when a menu opens
})

hl.layer_rule({
    match = { namespace = "logout_dialog" },
    blur = true,
    ignore_alpha = 0.5,
    dim_around = true,
})

local suppressMaximizeRule = hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

DesktopLaunchFloat = hl.window_rule({
    name = "desktop-launch-float",
    match = { class = ".*" },
    float = true,
    size = "1100 680",
    center = true,
})
DesktopLaunchFloat:set_enabled(false)

DesktopLaunchGame = hl.window_rule({
    name = "desktop-launch-game",
    match = { class = ".*" },
    no_anim = true,
})
DesktopLaunchGame:set_enabled(false)

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move = "20 monitor_h-120",
    float = true,
})

local mainMod = "ALT"
local terminal = "ghostty"
local fileManager = (os.getenv("HOME") or "~") .. "/.config/quickshell/desktop/explorer.sh"
local menu = "fuzzel"
local iconsToggle = "qs -c desktop ipc call desktop toggle"
local screenshotsDir = (os.getenv("HOME") or "~") .. "/downloads/screenshots"
local session = (os.getenv("HOME") or "~") .. "/git/dots/scripts/hypr/session.sh"
local browser = (os.getenv("HOME") or "~") .. "/git/dots/scripts/firefox/browser.sh"
local fcitxToggle = (os.getenv("HOME") or "~") .. "/git/dots/scripts/fcitx/toggle.sh"
local spawnTerminal = (os.getenv("HOME") or "~") .. "/git/dots/scripts/hypr/spawn-terminal.sh"
local fullWidth = (os.getenv("HOME") or "~") .. "/git/dots/scripts/hypr/full-width.sh"

hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(spawnTerminal))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("pkill pavucontrol || pavucontrol"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell kill -c hyprquickpaper || quickshell -c hyprquickpaper"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser .. " -p"))
local barRecover = (os.getenv("HOME") or "~") .. "/git/dots/scripts/hypr/bar-recover.sh"
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(barRecover))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(iconsToggle))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(session .. " -c"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(fcitxToggle))
local closeWindowBind = hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(
    mainMod .. " + SHIFT + O",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

hl.bind(mainMod .. " + SHIFT + Z", monitors.toggle_laptop_screen)

-- Copilot key: keyd turns it into F13 with Meta+Shift still held (notes: hyprland.md).
hl.bind(
    "code:191",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/git/dots/scripts/hypr/key-copilot-hermes.sh"),
    { ignore_mods = true }
)

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region -o " .. screenshotsDir))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -o " .. screenshotsDir))

hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next({ repeating = true }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind(mainMod .. " + D", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 1, client = 2, action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(fullWidth))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local keys = {
    left = { "h", "left", "l" },
    right = { "l", "right", "r" },
    up = { "k", "up", "u" },
    down = { "j", "down", "d" },
}
local deltas = {
    left = { x = -10, y = 0 },
    right = { x = 10, y = 0 },
    up = { x = 0, y = -10 },
    down = { x = 0, y = 10 },
}
for dir, v in pairs(keys) do
    local vim = v[1]
    local arrow = v[2]
    local delta = deltas[dir]
    hl.bind(mainMod .. " + " .. vim, hl.dsp.focus({ direction = dir }))
    for _, key in ipairs({ vim, arrow }) do
        hl.bind(
            mainMod .. " + CTRL + " .. key,
            hl.dsp.window.resize({ x = delta.x * 8, y = delta.y * 8, relative = true }),
            { repeating = true }
        )
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }), { repeating = true })
        hl.bind(
            mainMod .. " + SUPER + " .. key,
            hl.dsp.window.move({ x = delta.x * 5, y = delta.y * 5, relative = true }),
            { repeating = true }
        )
    end
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = i }))
        hl.exec_cmd("qs -c bar ipc call bar flashDots")
    end)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Hold SUPER + comma to peek at the desktop.
local peekFrom = nil
local function peekAnimation(style, speed)
    hl.animation({ leaf = "workspaces", enabled = true, speed = speed, bezier = "ease", style = style })
end
local function peekRestore()
    if peekFrom == nil then
        return
    end
    hl.dispatch(hl.dsp.focus({ workspace = peekFrom }))
    peekFrom = nil
    hl.timer(function()
        if peekFrom == nil then
            peekAnimation("slide", 2.427)
        end
    end, { timeout = 400, type = "oneshot" })
end
hl.bind("SUPER + comma", function()
    if peekFrom ~= nil then
        return
    end
    local ws = hl.get_active_workspace()
    if ws == nil or ws.special then
        return
    end
    peekFrom = ws.id
    peekAnimation("fade", 1.5)
    hl.dispatch(hl.dsp.focus({ workspace = "name:desktop" }))
end)
hl.bind("comma", peekRestore, { release = true, ignore_mods = true, non_consuming = true })
hl.bind("Super_L", peekRestore, { release = true, ignore_mods = true, non_consuming = true })

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + bracketleft", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + Left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.focus({ monitor = "r" }))

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
hl.bind(mainMod .. " + Minus", function()
    zoomfunction(-0.3)
end, { repeating = true, description = "Misc: Zoom out" })
hl.bind(mainMod .. " + Equal", function()
    zoomfunction(0.3)
end, { repeating = true, description = "Misc: Zoom in" })
hl.bind(mainMod .. " + mouse_down", function()
    zoomfunction(-0.3)
end, { repeating = true, description = "Misc: Zoom out" })
hl.bind(mainMod .. " + mouse_up", function()
    zoomfunction(0.3)
end, { repeating = true, description = "Misc: Zoom in" })

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true }
)

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
