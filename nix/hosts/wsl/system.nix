{ config, lib, pkgs, ... }: {

    #networking.hostName = "p1-wsl";
    #nixpkgs.hostPlatform = "x86_64-linux";
    #wsl.defaultUser = "nixos";
    system.stateVersion = "25.11";
    wsl.enable = true;
    imports = [
        <nixos-wsl/modules>
    ];

    #nix.settings = {
    #    experimental-features = [ "nix-command" "flakes" ];
    #    trusted-users = [ "root" "nixos" ];
    #    warn-dirty = false;
    #};

    # vscode
    programs.nix-ld.enable = true;
    environment.systemPackages = with pkgs; [
        wget
    ];
}
