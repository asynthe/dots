/*
   ⠀⣴⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⣼⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⣼⣿⣿⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣤⣶⣶⣿⣿⡗
  ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟
  ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀
  ⣿⣿⡇⠜⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ⠀
  ⣿⣿⣿⣶⣿⣿⣿⣿⣿⠋⡹⠙⣿⣿⣿⡇⠀⠀
  ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣿⣿⠛⠀⠀⠀⠀⠀
  ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠁⠀⠀⠀⠀⠀⠀
  ⣿⣿⡿⠻⠿⠿⠿⠿⠛⠹⠑
  ⠟

  asynthe's system flake, 2026
  refer to readme.md for more information on how to use this flake.
*/

{
    description = "asynthe's system flake";
    inputs = {

        # Main
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # Other
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        nixgl.url = "github:nix-community/nixGL";
        nixgl.inputs.nixpkgs.follows = "nixpkgs";

        # Other 2
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        impermanence.url = "github:nix-community/impermanence";
        lanzaboote.url = "github:nix-community/lanzaboote";
        lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
        musnix.url = "github:musnix/musnix";
        sops-nix.url = "github:Mic92/sops-nix";

        # Apps
        swww.url = "github:LGFae/swww";
        norgolith.url = "github:NTBBloodbath/norgolith";

    };

    outputs = {
        self,
        nixpkgs,
        nixpkgs-stable,
        home-manager,
        nixgl,
        ...
    } @ inputs:

    let
        inherit (nixpkgs) lib;
        inherit (self) outputs;

        hostDirs = builtins.attrNames (
            lib.filterAttrs
                (name: type: type == "directory")
                (builtins.readDir ./nix/hosts)
        );

        homeDirs = builtins.attrNames (
            lib.filterAttrs
                (name: type: type == "directory")
                (builtins.readDir ./nix/home)
        );

        mkPkgs = nixpkgsInput: arch:
            import nixpkgsInput {
                system = arch;
                config.allowUnfree = true;
            };

        mkArchConfig = path:
            let
                archConfig = import path;
                arch = archConfig.arch;
                channel = archConfig.channel;
                nixglPkgs = nixgl.packages.${arch};

                pkgs =
                    if channel == "unstable" then
                        mkPkgs nixpkgs arch
                    else if channel == "stable" then
                        mkPkgs nixpkgs-stable arch
                    else
                        throw "Invalid channel '${channel}' in ${toString path}";
            in {
                inherit arch channel pkgs nixglPkgs;
                pkgs-stable = mkPkgs nixpkgs-stable arch;
            };

        mkHost = host:
            let
                cfg = mkArchConfig ./nix/hosts/${host}/arch.nix;
            in {
                name = host;

                value = lib.nixosSystem {
                    system = cfg.arch;
                    pkgs = cfg.pkgs;

                    specialArgs = {
                        inherit inputs outputs;
                        channel = cfg.channel;
                        pkgs-stable = cfg.pkgs-stable;
                        nixglPkgs = cfg.nixglPkgs;
                    };

                    modules = [
                        ./nix/hosts/${host}
                        inputs.sops-nix.nixosModules.sops
                        inputs.disko.nixosModules.disko
                        inputs.impermanence.nixosModules.impermanence
                        inputs.lanzaboote.nixosModules.lanzaboote
                        inputs.musnix.nixosModules.musnix
                    ];
                };
            };

        mkHome = user:
            let
                cfg = mkArchConfig ./nix/home/${user}/arch.nix;
            in {
                name = user;
                value = home-manager.lib.homeManagerConfiguration {
                    pkgs = cfg.pkgs;

                    extraSpecialArgs = {
                        inherit inputs outputs;
                        channel = cfg.channel;
                        pkgs-stable = cfg.pkgs-stable;
                        nixglPkgs = cfg.nixglPkgs;
                    };

                    modules = [
                        ./nix/home/${user}
                    ];
                };
            };

    in {
        nixosConfigurations =
            builtins.listToAttrs (map mkHost hostDirs);

        homeConfigurations =
            builtins.listToAttrs (map mkHome homeDirs);
    };
}
