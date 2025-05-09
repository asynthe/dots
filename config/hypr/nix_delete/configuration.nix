{ config, lib, pkgs, ... }:
let
    # Monitors
    monitor1 = "eDP-1";
    monitor2 = "HDMI-A-3";

    # Modkeys
    modkey = "ALT";
    modkey2 = "SUPER";
in {

    wayland.windowManager.hyprland.settings = {
        xwayland.force_zero_scaling = true; # Xwayland apps look like shit when scaled.
        debug.disable_logs = false;
    
        exec-once = [
            "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1 &"
            "mullvad-gui &"
            "qbittorrent &"
            #"waybar &"
        ];
    
        env = [
    
            # ENABLE WHEN NVIDIA IS CONFIGURED
            # MAKES HYPRLAND WORK ON NVIDIA TEST
            "LIBVA_DRIVER_NAME,nvidia"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            #"WLR_NO_HARDWARE_CURSORS, 1" # Fix for cursor not appearing on nvidia drivers.
    
            # XDG and Portal
            "XDG_SESSION_TYPE,wayland"
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
    
            # Vars for Electron
            "NIXOS_OZONE_WL, 1"
            "MOZ_ENABLE_WAYLAND, 1" # Firefox in Wayland.
    
            # Cursor
            # CHECK IF PROBLEM EXISTS AND ENABLE cursor:no_hardware_cursors
            "HYPRCURSOR_SIZE,32"
            "XCURSOR_SIZE,32"
        ];
    
        monitor = [
    
            # Last variable is scaling, I use 1.20 sometimes.
            # Configuration
            "${monitor1}, 2560x1600@120, 1920x0, 1.25"
            "${monitor2}, 1920x1080@60, 0x0, 1"
    
            # eDP-1
            #"${monitor1}, 3840x2400@120, 0x0, 2"
            #"${monitor1}, 2560x1600@120, 0x0, 1.25"
    
            # eDP-1 on the left
            #"${monitor1}, 1920x1080@60, 0x0, 1" 
            #"${monitor2}, 1920x1080@60, 1920x0, 1"
    
            # eDP-1 on the right
            #"${monitor1}, 1920x1080@60, 1920x0, 1"
            #"${monitor1}, 2560x1600@120, 1920x0, 1.25"
            #"${monitor2}, 1920x1080@60, 0x0, 1"
    
            # Disable eDP-1
            #"${monitor1}, disable"
            #"$(monitor2), disable"
    
            # Vertical
            #"${monitor2}, 1920x1080@60, 0x0, 1, transform, 1"
        ];
    
        workspace = [
            "special, border: 0"
            "1,monitor:HDMI-A-3" # Make monitor take wksp 1 when connected
        ];
    
        device = {
            # Old Razer Hyperspeed X mouse
            name = "razer-razer-basilisk-x-hyperspeed-1";
            #name = "razer-razer-basilisk-x-hyperspeed";
            sensitivity = "-0.8"; # from -1.0 to 1.0, default 0.0
            accel_profile = "flat";
        };
    
        general = {
            layout = "dwindle";
            gaps_in = 4; # prev 4
            gaps_out = 10; # prev 10
            border_size = 1;
            #no_border_on_floating = 1;
            # Border color -> Stylix
        };
    
        # Animations
        # See more at https://wiki.hyprland.org/Configuring/Animations
        # Anymations types: slide, slidevert, fade, slidefade, slidefadevert.
        animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
                "windows, 1, 7, myBezier"
                "windowsOut, 1, 7, default, popin 80%"
                "border, 1, 10, default"
                "fade, 1, 7, default"
                "workspaces, 1, 6, default, slide"
                "specialWorkspace, 1, 3, default, fade"
            ];
        };
    
        dwindle = {
            preserve_split = true;
            no_gaps_when_only = true; # Smart gaps, no gaps when only one window.
            smart_split = false;
            smart_resizing = false;
            special_scale_factor = 0.98; # Scale of special workspace windows.
        };
    
        master = {
            new_status = "master"; # master, slave, inherit.
            inherit_fullscreen = true;
            #no_gaps_when_only = true; # Smart gaps, no gaps when only one window.
        };
    
        gestures = {
            workspace_swipe = true;
        };
    
        decoration = {
            rounding = 0;
            active_opacity = 1;
            inactive_opacity = 1; # prev 0.82
            fullscreen_opacity = 1;
    
            # Blur
            blur = {
                enabled = true;
                size = 3;
                passes = 3;
                new_optimizations = true;
                xray = false; # Terminal see-through apps.
                special = false;
            };
    
            # Shadows
            drop_shadow = false;
            shadow_range = 4;
            shadow_render_power = 3;
            shadow_ignore_window = true;
            #"col.shadow" = "rgba(1a1a1aee)"; # Stylix
            #"col.shadow_inactive" = "...";
    
            # Dim
            dim_inactive = false;
            dim_strength = 0.5;
            dim_around = 0.4;
            dim_special = 0.4;
        };
    
        # Misc
        misc = {
            initial_workspace_tracking = 1; # Only first window. (2 for window + children)
            key_press_enables_dpms = true;
    
            # Cursor
            #inactive_timeout = 3;
            #hide_on_key_press = true; # Hide cursor on key press.
    
            # Window Swallowing
            enable_swallow = true;
            #swallow_regex = "^(Alacritty|kitty|org.wezfurlong.wezterm)$"; # works btw
    
            # Hyprland logo
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            #force_hypr_change = false;
    
            # VRR (Variable Refresh Rate)
            # https://wiki.archlinux.org/title/Variable_refresh_rate
            # Requires a monitor with G-SYNC (NVIDIA) or FreeSync (AMD).
            #vrr = 1;
        };
    
        # -------------- Window Rules --------------
        layerrule = [
            "noanim, wofi"
            "noanim, wshowkeys"
        ];
        windowrulev2 = [
            "noanim, floating: 1"
    
            # Chromium
            "center, class:(chromium), title:(Save File)"
            "float, class:(chromium), title:(Save File)"
            "noborder, class:(chromium), title:(Save File)"
            "opacity 1.0 override 1.0 override, class:(Save File)"
            "opacity 1.0 override 1.0 override, class:(chromium)"
    
            # Firefox (Librewolf), Picture-in-Picture
            "opacity 1.0 override 1.0 override, class:^(librewolf)$"
            "idleinhibit focus, class:^(librewolf)$, title:^(.*YouTube.*)$"
            "idleinhibit fullscreen, class:^(librewolf)$"
            "opacity 1.0 override 1.0 override, title:^(Enter name of file to save to...)$"
            "center, title:^(Enter name of file to save to...)$"
            "noanim, title:^(Enter name of file to save to...)$"
            "noborder, title:^(Enter name of file to save to...)$"
            # Firefox - Picture-in-Picture - ピクチャーインピクチャー
            "center, title:^(Picture-in-Picture)$" # ADD move to right bottom corner
            "float, title:^(Picture-in-Picture)$"
            "noanim, title:^(Picture-in-Picture)$"
            "noborder, title:^(Picture-in-Picture)$"
            "nodim, title:^(Picture-in-Picture)$"
            "nodim, title:^(ピクチャーインピクチャー)$"
            "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
            "pin, title:^(Picture-in-Picture)$"
    
            # Hypnotix
            "float, class:^(Hypnotix.py)$"
            "idleinhibit always, class:^(Hypnotix.py)$"
            "pin, class:^(Hypnotix.py)$"
            #"size 723 408, class:^(Hypnotix.py)$
            #"move 43% 45%, class:^(Hypnotix.py)$  
            #"move 44% 45%, class:^(Hypnotix.py)$  
            #"move 849 489, class:^(Hypnotix.py)$
            #"move 55% 49%, class:^(Hypnotix.py)$
    
            # KeepassXC
            "float, class:^(org.keepassxc.KeePassXC)$"
            "noanim, class:^(org.keepassxc.KeePassXC)$"
    
            # mpv
            "opacity 1.0 override 1.0 override, class:^(mpv)$"
            "idleinhibit focus, class:^(mpv)$"
            "idleinhibit fullscreen, class:^(mpv)$"
    
            # Mullvad
            "float, title:(Mullvad VPN)"
            "noanim, title:(Mullvad VPN)"
            "noborder, title:(Mullvad VPN)"
            "opacity 1.0 override 1.0 override, title:(Mullvad VPN)"
            "workspace 10 silent, title:(Mullvad VPN)"
            #"move 3520 512, title:(Mullvad VPN)"
            #"move -100%, title:(Mullvad VPN)"
    
            # pavucontrol
            "float, class:^(pavucontrol)$"
            "noanim, class:pavucontrol.*$"
            "noborder, class:^(pavucontrol)$"
            "center, class:^(pavucontrol)$"
            "size 800 500, class:^(pavucontrol)$"
    
            # Qbittorrent
            "workspace 10 silent, class:^(org.qbittorrent.qBittorrent)$"
            "noanim, class:^(org.qbittorrent.qBittorrent)$"
    
            # Steam
            "idleinhibit always, class:^(steam)$"
            "minsize 1 1, title:^()$,class:^(steam)$"
            "stayfocused, title:^()$,class:^(steam)$"
    
            # Waydroid
            "float, title:^(Waydroid)$"
    
            # Wezterm
            "float, class:^(org.wezfurlong.wezterm)$"
            "tile, class:^(org.wezfurlong.wezterm)$"
    
            # Zathura
            #"noanim, class:(org.pwmt.zathura)$"
            "opacity 1.0 override 1.0 override, class:(org.pwmt.zathura)$"
    
            # Vmware
            #"fakefullscreen, class:^(Vmware)$"
            "float, class:^(Vmware)$"
            "opacity 1.0 override 1.0 override, class:^(Vmware)$"
            #"center, title:^(Open Virtual Machines)$,class:^(Vmware)$"
            #"float, title:^(Open Virtual Machines)$,class:^(Vmware)$"
    
            # Other
            "center, class:^(org.kde.polkit-kde-authentication-agent-1)$"
            #"fakefullscreen, class:VirtualBoxVM"
            #"fakefullscreen, class:org.telegram.desktop"
            "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
            "float, class:^(org.qgis.)$"
            "float, title:^(Media viewer)$" # Telegram media viewer
            #"float, class:^(Anki)$"
            #"move 66% 54%, class:^(Anki)$"
            #"noanim, class:^(Anki)$"
    
            # Sharing Indicators
            "workspace special silent, title:^(Firefox — Sharing Indicator)$"
            "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
        ];
    
        # -------------- Keybinds --------------
        "$mainMod" = "${modkey}";
    
        input = {
            follow_mouse = 1;
            kb_layout = "us";
            kb_options = "caps:swapescape";
            sensitivity = 0;
            touchpad.natural_scroll = false;
        };
    
        bind = [
            # Apps
            #"$mainMod SHIFT, return, exec, [float;tile] ${pkgs.wezterm}/bin/wezterm start --always-new-process"
            "$mainMod SHIFT, return, exec, [tile] alacritty"
            "$mainMod, p, exec, pkill ${pkgs.wofi}/bin/wofi || ${pkgs.wofi}/bin/wofi --show drun"
            "$mainMod, v, exec, [float] pkill ${pkgs.pavucontrol}/bin/pavucontrol || ${pkgs.pavucontrol}/bin/pavucontrol"
            #"${modkey2}, b, exec, pkill ${pkgs.waybar}/bin/waybar || ${pkgs.waybar}/bin/waybar"
    
            # Screenshots
            "${modkey2}, s, exec, ${pkgs.hyprshot}/bin/hyprshot --raw --mode region | ${pkgs.swappy}/bin/swappy --file -"
            "${modkey2} SHIFT, s, exec, ${pkgs.hyprshot}/bin/hyprshot --raw --mode window | ${pkgs.swappy}/bin/swappy --file -"
            "${modkey2} CTRL, s, exec, ${pkgs.hyprshot}/bin/hyprshot --raw --mode output | ${pkgs.swappy}/bin/swappy --file -"
    
            # Actions
            "$mainMod SHIFT, c, killactive,"
            "$mainMod SHIFT, o, exit,"
    
            # Actions - Windows
            "$mainMod SHIFT, p, pin,"
            "$mainMod SHIFT, f, togglefloating,"
            "$mainMod SHIFT, m, togglefloating,"
            "$mainMod, d, togglesplit," # Dwindle
            "$mainMod, f, fullscreen,"
            "$mainMod, m, fullscreen,"
            #"$mainMod, n, fakefullscreen,"
            "$mainMod, o, pseudo," # Dwindle
    
            # Windows - Focus
            "$mainMod, h, movefocus, l"
            "$mainMod, j, movefocus, d"
            "$mainMod, k, movefocus, u"
            "$mainMod, l, movefocus, r"
    
            # Windows - Swap
            "$mainMod SHIFT, h, movewindow, l"
            "$mainMod SHIFT, j, movewindow, d"
            "$mainMod SHIFT, k, movewindow, u"
            "$mainMod SHIFT, l, movewindow, r"
    
            # Monitor and Workspace focus
            "$mainMod, comma, focusmonitor, -1"
            "$mainMod, period, focusmonitor, +1"
            "$mainMod SHIFT, comma, workspace, e-1"
            "$mainMod SHIFT, period, workspace, e+1"
    
            # Switch workspaces with mouse scroll
            "$mainMod, mouse_up, workspace, e-1"
            "$mainMod, mouse_down, workspace, e+1"
    
            # Workspaces
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"
            "$mainMod, s, togglespecialworkspace" # Scratchpad
    
            # Workspaces - Move window to workspace
            "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
            "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
            "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
            "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
            "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
            "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
            "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
            "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
            "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
            "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
            "$mainMod SHIFT, s, movetoworkspacesilent, special" # Move to scratchpad
        ];
    
        binde = [
            # Windows - Resize
            "$mainMod CTRL, h, resizeactive, -5% 0"
            "$mainMod CTRL, j, resizeactive, 0 5%"
            "$mainMod CTRL, k, resizeactive, 0 -5%"
            "$mainMod CTRL, l, resizeactive, 5% 0"
    
            # Audio - Pipewire / Wireplumber
            ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" # Mute mic
    
            # Brightness - brightnessctl
            ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%+"
            ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
    
            # Audio + Brightness - swayOSD # TEST
            #", XF86AudioRaiseVolume, exec, ${pkgs.swayosd}/bin/swayosd --output-volume=raise"
            #", XF86AudioLowerVolume, exec, ${pkgs.swayosd}/bin/swayosd --output-volume=lower"
            #", XF86MonBrightnessUp, exec, ${pkgs.swayosd}/bin/swayosd --brightness=raise"
            #", XF86MonBrightnessDown, exec, ${pkgs.swayosd}/bin/swayosd --brightness=lower"
        ];
    
        bindl = [
            # Audio - playerctl # TEST
            #", XF86AudioMute, exec, ${pkgs.swayosd}/bin/swayosd --output-volume mute-toggle"
            #", XF86AudioMicMute, exec, ${pkgs.swayosd}/bin/swayosd ???" # Mute mic
            #", XF86AudioPrev, exec, playerctl previous"
            #", XF86AudioPlay, exec, playerctl play-pause"
            #", XF86AudioNext, exec, playerctl next"
            #", XF86AudioStop, exec, playerctl stop"
        ];
    
        bindm = [
            # Windows - Resize with Mouse
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
        ];
    };
}
