{ ... }:
{
    flake.modules.nixos.atuin = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ atuin ];
    };

    flake.modules.nixos.gimp = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ gimp-with-plugins ];
    };

    flake.modules.nixos.kiwix = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ kiwix ];
    };

    flake.modules.nixos.irc = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            irssi
            weechat
        ];
    };

    flake.modules.nixos.music = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            cava
            cliamp
            cmus
            mixxx
            mpd ncmpcpp rmpc
            spek
            #projectm_3 # Milkdrop 3
        ];
    };

    flake.modules.nixos.monero = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            monero-cli
            monero-gui
        ];
    };

    flake.modules.nixos.qbittorrent = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ qbittorrent ];
    };

    flake.modules.nixos.paraview = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ paraview ];
    };

    flake.modules.nixos.tectonic = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ tectonic ];
    };

    flake.modules.nixos.typst = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            typst

            et-book
            garamond-libre
            nerd-fonts.zed-mono
        ];
    };

    flake.modules.nixos.flatpak = { config, lib, ... }: {
        services.flatpak.enable = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/flatpak" ];
    };

    flake.modules.nixos.nh = { config, ... }: {
        programs.nh = {
            enable          = true;
            clean.enable    = true;
            clean.extraArgs = "--keep-since 4d --keep 3";
            flake           = config.sys.flake;
        };
    };
}
