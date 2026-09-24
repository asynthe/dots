{ inputs, ... }:
{
    flake.modules.nixos.core = { config, lib, pkgs, ... }: {

        imports = [ inputs.impermanence.nixosModules.impermanence ];

        nixpkgs.config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
        };

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

        programs.zsh.enable = true;
        environment.localBinInPath = true;
        users.users = lib.genAttrs config.sys.admins
            (_: { extraGroups = [ "audio" "networkmanager" ]; });

        security.sudo.extraConfig = ''
            # Ask for password every 2 hours
            Defaults timestamp_timeout=120
            # rollback results in sudo lectures after each reboot
            Defaults lecture = never
        '';
    };
}
