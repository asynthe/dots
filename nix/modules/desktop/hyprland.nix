_: {
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    systemd.packages = [ pkgs.hyprpolkitagent ];
    systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

    systemd.user.services."hyprland-dpms-resume" = {
      description = "Re-enable Hyprland displays after resume";
      after = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      wantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        ExecStart = "${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
      };
    };

    environment.systemPackages = with pkgs; [

      brightnessctl
      fuzzel
      rofi
      walker
      elephant
      gromit-mpx
      hypridle
      hyprshot
      mako
      libnotify
      playerctl
      ripdrag
      socat
      wl-clipboard

      awww
      waypaper
      linux-wallpaperengine

      hyprpolkitagent
      adw-gtk3
    ];
  };
}
