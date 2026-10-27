{ ... }:
{
    flake.modules.nixos.boot = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.efibootmgr ];

        boot.loader.efi.efiSysMountPoint             = "/efi";
        boot.loader.efi.canTouchEfiVariables         = true;
        boot.loader.systemd-boot.enable              = true;
        boot.loader.systemd-boot.configurationLimit  = 4;
        boot.loader.timeout                          = 3;

        # Menu titles as "NixOS Linux (7.3) Gen 12" instead of "NixOS" plus the
        # long "Generation 12 Zokor 26.11..., built on ..." version suffix.
        # Only the title line changes: version/sort-key stay, so ordering holds.
        # Entries are content-hashed, so the builder rewrites edited ones every
        # switch and this re-titles them again; harmless churn on the ESP.
        boot.loader.systemd-boot.extraInstallCommands = ''
            for e in /efi/loader/entries/nixos-*.conf; do
                [ -e "$e" ] || continue
                ${pkgs.gnugrep}/bin/grep -q '^title NixOS Linux (' "$e" && continue   # already done
                gen=$(${pkgs.gnused}/bin/sed -n 's/^version Generation \([0-9]*\).*/\1/p' "$e")
                kver=$(${pkgs.gnused}/bin/sed -n 's|^linux .*-linux-\([0-9][^-]*\)-bzImage.*|\1|p' "$e")
                [ -n "$gen" ] || continue
                # keep any " [profile]" / " (specialisation)" suffix after "NixOS"
                extra=$(${pkgs.gnused}/bin/sed -n 's/^title NixOS//p' "$e")
                ${pkgs.gnused}/bin/sed -i "s|^title .*|title NixOS Linux (''${kver:-?}) Gen $gen$extra|" "$e"
            done
        '';
    };
}
