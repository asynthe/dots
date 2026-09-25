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

    flake.modules.nixos.rpcs3 = { pkgs, ... }:
    let
        rpcs3-bin = pkgs.appimageTools.wrapType2 {
            pname   = "rpcs3";
            version = "0.0.41-19515-a7fc31f3";
            src     = pkgs.fetchurl {
                url    = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-a7fc31f3212c55bf0b70b45875c52dfc94f6641a/rpcs3-v0.0.41-19515-a7fc31f3_linux64.AppImage";
                sha256 = "1jbldny7k2qx4apbp9nd9m4j79w5pgdzykb47wsc80rzav0xsxaw";
            };
        };
    in {
        assertions = [{
            assertion = pkgs.stdenv.hostPlatform.isx86_64 && pkgs.stdenv.hostPlatform.isLinux;
            message   = "rpcs3: AppImage is only available for x86_64-linux";
        }];
        environment.systemPackages = [ rpcs3-bin ];
    };

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
    in {
        assertions = [{
            assertion = pkgs.stdenv.hostPlatform.isx86_64 && pkgs.stdenv.hostPlatform.isLinux;
            message   = "emulation-station: AppImage is only available for x86_64-linux";
        }];
        environment.systemPackages = [ emulation-station-bin ];
    };
}
