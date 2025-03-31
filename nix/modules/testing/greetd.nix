{ pkgs, ... }: {

    # Note: not working for me with Hyprland master branch ver.
    # idk why lol

    services.greetd = {
        enable = true;
	    settings = {
	    default_session = {
		    user = "greeter";
	        command = builtins.concatStringsSep " " [
                "${pkgs.greetd.tuigreet}/bin/tuigreet"
                "--time" 
                "--asterisks"
                "--remember" 
                "--remember-session" 
                "--greeting 'Welcome to NixOS! ^_^'" 
                #"--sessions ${inputs.hyprland.packages.${pkgs.system}.hyprland}/share/wayland-sessions" # When using Hyprland master branch.
                "--sessions ${pkgs.hyprland}/share/wayland-sessions"
                ];
	        };
	    };
    };

    # Clean greetd of any tty noise.
    # https://github.com/sjcobb2022/nixos-config/blob/main/hosts/common/optional/greetd.nix
    systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal"; # Without this errors will spam on the screen.
        # Without these bootlogs will spam on screen
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
    };
}
