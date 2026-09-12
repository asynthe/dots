# Imported by every host: nix daemon settings, the primary user, the nixpkgs instance.
{ inputs, ... }:
{
    flake.modules.nixos.core = { config, pkgs, ... }: {

        # Always available, so aspects can declare persistence unconditionally.
        imports = [ inputs.impermanence.nixosModules.impermanence ];

        nixpkgs.config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
        };

        # flannel 0.28.6 has a wrong hash in nixpkgs; actual hash from upstream
        nixpkgs.overlays = [
            (final: prev: {
                flannel = prev.flannel.overrideAttrs (old: {
                    src = old.src.overrideAttrs (_: {
                        outputHash = "sha256-sqpsUAKBza96AMQMUCG94KOht5ExnHRLR7eGna3m3Xg=";
                    });
                });
            })
        ];

        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.settings.warn-dirty = false;

        i18n.defaultLocale = "en_US.UTF-8";
        services.fstrim.enable = true;

        # Shell
        programs.zsh.enable = true;
        users.users.${config.sys.user} = {
            shell = pkgs.zsh;
            isNormalUser = true;
            extraGroups = [ "audio" "networkmanager" "input" "wheel" ];
        };

        security.sudo.extraConfig = ''
            # Ask for password every 2 hours
            Defaults timestamp_timeout=120
            # rollback results in sudo lectures after each reboot
            Defaults lecture = never
        '';
    };
}
