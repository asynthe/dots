{ pkgs, ... }:
let
    user = "meow";
in {
    networking.hostName  = "base";
    system.stateVersion  = "25.05";
    i18n.defaultLocale   = "en_US.UTF-8";
    time.timeZone        = "America/Santiago";

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.warn-dirty = false;

    programs.zsh.enable = true;
    users.users.${user} = {
        shell          = pkgs.zsh;
        isNormalUser   = true;
        initialPassword = "meows123";
        extraGroups    = [ "audio" "networkmanager" "input" "wheel" ];
    };

    sys.modules = {
        boot.enable       = true;
        networking.enable = true;
        ssh.enable        = true;
        nh.enable         = true;
        git.enable        = true;
    };
}
