/*
I got it running with the next commands.
`pkill gpg-agent` (If gpg-agent is running)
`gpg-agent --pinentry-program=/home/user/.nix-profile/bin/pinentry-curses --daemon`
*/

{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.password-store;
in {
    options.sys.modules.password-store = {
        enable = lib.mkEnableOption "password-store";
    };

    config = lib.mkIf cfg.enable {
        programs.gnupg.agent = {
            enable = true;
            pinentryPackage = pkgs.pinentry-curses;
        };
        environment.systemPackages = with pkgs; [
            pass-wayland
        ];
    };
}
