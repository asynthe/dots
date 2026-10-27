{ ... }:
{
    flake.modules.nixos.controller = { config, lib, pkgs, ... }: {
        hardware.xpadneo.enable = true;
        users.users             = lib.genAttrs config.sys.admins (_: { extraGroups = [ "input" ]; });
        environment.systemPackages = with pkgs; [
            dualsensectl
        ];
    };
}
