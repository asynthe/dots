# TODO Check if all of this is good
# TODO Check this links
# https://github.com/jankrejci/dotfiles/blob/f6f73d67db8ad09fb8ebc6239a5b1980c1232ddd/modules/disk-tpm-encryption.nix#L168

{ pkgs, lib, ... }: {

    environment.systemPackages = with pkgs; [ sbctl e2fsprogs ];
    boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        autoGenerateKeys.enable = true;
        autoEnrollKeys.enable = true;
        autoEnrollKeys.autoReboot = true;
    };

    boot.loader.timeout = null;
    boot.loader.efi.efiSysMountPoint = "/efi";
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.systemd-boot.configurationLimit = 3;

    # This bricked my system lol
    #boot.loader.systemd-boot.extraEntries = {
    #    "windows.conf" = ''
    #        title       Windows 11
    #        efi         /EFI/Microsoft/Boot/bootmgfw.efi
    #    '';
    #};

    # ─────────────── Windows ───────────────
    # TODO Test
    # Remember to set this in Windows for a correct time between systems
    # https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows
    #time.hardwareClockInLocalTime = true;

    # OLD 
    #loader.timeout = null;
    #loader.systemd-boot.enable = true;
    #loader.systemd-boot.configurationLimit = 3;

    # I prefer to have Windows with it's own drive and efi
    # from https://mynixos.com/nixpkgs/option/boot.loader.systemd-boot.windows.%3Cname%3E.efiDeviceHandle
    #loader.systemd-boot.edk2-uefi-shell.enable = true;
    #boot.loader.systemd-boot.windows."windows" = {
    #    title = "Michaelsoft Binbows 11";
    #    efiDeviceHandle = "HD0d";
    #    sortKey = "z_windows"; # push to bottom
    #};
}
