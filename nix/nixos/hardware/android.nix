{ ... }:
{
    flake.modules.nixos.android = { config, lib, pkgs, ... }: {
        #programs.nix-ld.enable = true;
        #programs.nix-ld.libraries = [ pkgs.libGL pkgs.glib ];

        #virtualisation.waydroid.enable = true;
        #services.gvfs.enable = true;
        users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "kvm" "adbusers" ]; });
        environment.systemPackages = with pkgs; [
            #androidsdk
            android-tools
            #android-studio
            #jmtpfs
            scrcpy
        ];
    };
}
