_: {
  # Launched as `es-de`: state goes to XDG_DATA_HOME instead of ~/ES-DE, and
  # it runs on the dGPU so every emulator it spawns inherits the offload.
  flake.modules.nixos.emulation-station =
    { pkgs, ... }:
    let
      emulation-station-bin = pkgs.appimageTools.wrapType2 {
        pname = "es-de";
        version = "3.4.1";
        src = pkgs.fetchurl {
          url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/288156961/download";
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
    in
    {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isx86_64 && pkgs.stdenv.hostPlatform.isLinux;
          message = "emulation-station: AppImage is only available for x86_64-linux";
        }
      ];
      environment.systemPackages = [
        emulation-station
        (pkgs.makeDesktopItem {
          name = "es-de";
          desktopName = "ES-DE";
          comment = "Emulator frontend";
          exec = "es-de";
          icon = "applications-games";
          categories = [ "Game" ];
        })
      ];
    };
}
