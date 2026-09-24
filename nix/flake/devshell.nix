{ ... }:
{
    perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
            packages = with pkgs; [
                age
                nix-output-monitor
                sops
                ssh-to-age
            ];
        };
    };
}
