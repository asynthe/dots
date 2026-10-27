{ ... }:
{
    flake.modules.nixos.web-dev = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bruno
            hugo
            p7zip
        ];
    };
}
