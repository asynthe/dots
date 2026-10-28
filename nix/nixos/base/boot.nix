{ ... }:
{
    flake.modules.nixos.boot = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.efibootmgr ];

        boot.loader.efi.efiSysMountPoint             = "/efi";
        boot.loader.efi.canTouchEfiVariables         = true;
        boot.loader.systemd-boot.enable              = true;
        boot.loader.systemd-boot.configurationLimit  = 4;
        boot.loader.timeout                          = 3;

        # Short menu titles, "NixOS Linux (7.3) Gen 12" (docs/nix.md).
        boot.loader.systemd-boot.extraInstallCommands = ''
            for e in /efi/loader/entries/nixos-*.conf; do
                [ -e "$e" ] || continue
                ${pkgs.gnugrep}/bin/grep -q '^title NixOS Linux (' "$e" && continue
                gen=$(${pkgs.gnused}/bin/sed -n 's/^version Generation \([0-9]*\).*/\1/p' "$e")
                kver=$(${pkgs.gnused}/bin/sed -n 's|^linux .*-linux-\([0-9][^-]*\)-bzImage.*|\1|p' "$e")
                [ -n "$gen" ] || continue
                extra=$(${pkgs.gnused}/bin/sed -n 's/^title NixOS//p' "$e")
                ${pkgs.gnused}/bin/sed -i "s|^title .*|title NixOS Linux (''${kver:-?}) Gen $gen$extra|" "$e"
            done
        '';
    };
}
