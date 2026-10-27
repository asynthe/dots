{ ... }:
{
    flake.modules.nixos.hyprglass = { config, lib, pkgs, ... }: {
        environment.systemPackages = [
            (pkgs.hyprlandPlugins.mkHyprlandPlugin (final: {
                pluginName = "hyprglass";
                version    = "0.7.0";
                hyprland   = config.programs.hyprland.package;

                src = pkgs.fetchFromGitHub {
                    owner = "hyprnux";
                    repo  = "hyprglass";
                    tag   = "v${final.version}";
                    hash  = "sha256-x/584kY+XXlU/OWKtZAFo89VtowjLXs1DiP9PC0o0Os=";
                };

                installPhase = ''
                    runHook preInstall
                    install -Dm755 hyprglass.so $out/lib/libhyprglass.so
                    runHook postInstall
                '';

                meta = {
                    description = "Liquid Glass effect for Hyprland";
                    homepage    = "https://github.com/hyprnux/hyprglass";
                    license     = lib.licenses.bsd3;
                    platforms   = lib.platforms.linux;
                };
            }))
        ];
    };
}
