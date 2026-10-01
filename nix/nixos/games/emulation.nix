{ ... }:
{
    flake.modules.nixos.eden = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ eden ];
    };

    flake.modules.nixos.ryubing = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ ryubing ];
    };

    flake.modules.nixos.pcsx2 = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ pcsx2 ];
    };

    flake.modules.nixos.xenia = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ xenia-canary ];
    };

    flake.modules.nixos.dolphin = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ dolphin-emu ];
    };

    flake.modules.nixos.cemu = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ cemu ];
    };

    flake.modules.nixos.azahar ={ pkgs, ... }: {
        environment.systemPackages = with pkgs; [ azahar ];
    };

    flake.modules.nixos.ppsspp = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ ppsspp ];
    };

    flake.modules.nixos.rpcs3 = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ rpcs3 ];
    };

    # Cores are exposed at /run/current-system/sw/lib/retroarch/cores, which is
    # where ES-DE's custom find rules (config/ES-DE/custom_systems) look.
    flake.modules.nixos.retroarch = { pkgs, ... }: {
        environment.pathsToLink = [ "/lib/retroarch" ];
        environment.systemPackages = [
            (pkgs.retroarch.withCores (c: with c; [
                mesen           # nes
                snes9x          # snes
                mgba            # gb gbc gba
                mupen64plus     # n64
                melondsds       # nds
                beetle-psx-hw   # psx
                ppsspp          # psp
            ]))
        ];
    };

    # Launched as `es-de`: state goes to XDG_DATA_HOME instead of ~/ES-DE, and
    # it runs on the dGPU so every emulator it spawns inherits the offload.
    flake.modules.nixos.emulation-station = { pkgs, ... }:
    let
        emulation-station-bin = pkgs.appimageTools.wrapType2 {
            pname   = "es-de";
            version = "3.4.1";
            src     = pkgs.fetchurl {
                url    = "https://gitlab.com/es-de/emulationstation-de/-/package_files/288156961/download";
                sha256 = "109mfa3aag6x4gf08326cbgs09dl403ygvaqm8yicmcdfd6s8q9w";
            };
        };
        emulation-station = pkgs.writeShellScriptBin "es-de" ''
            export ESDE_APPDATA_DIR="''${ESDE_APPDATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/ES-DE}"
            if command -v nvidia-offload >/dev/null; then
                exec nvidia-offload ${emulation-station-bin}/bin/es-de "$@"
            fi
            exec ${emulation-station-bin}/bin/es-de "$@"
        '';
    in {
        assertions = [{
            assertion = pkgs.stdenv.hostPlatform.isx86_64 && pkgs.stdenv.hostPlatform.isLinux;
            message   = "emulation-station: AppImage is only available for x86_64-linux";
        }];
        environment.systemPackages = [
            emulation-station
            (pkgs.makeDesktopItem {
                name        = "es-de";
                desktopName = "ES-DE";
                comment     = "Emulator frontend";
                exec        = "es-de";
                icon        = "applications-games";
                categories  = [ "Game" ];
            })
        ];
    };
}
