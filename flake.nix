{
    description = "asynthe's system flake";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        disko.inputs.nixpkgs.follows = "nixpkgs";
        disko.url = "github:nix-community/disko";
        impermanence.url = "github:nix-community/impermanence";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
        nvf.url = "github:notashelf/nvf";
        sops-nix.url = "github:Mic92/sops-nix"; # TODO

        # Testing
        lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
        lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = {
        self,
        nixpkgs,
        nixpkgs-stable,
        home-manager,
        lanzaboote,

        nixos-wsl,
        nvf,
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
                    config = {
                        allowUnfree = true;
                        android_sdk.accept_license = true;
                    };
                };

            mkArchConfig = path:
                let
                    archConfig = import path;
                    arch = archConfig.arch;
                    channel = archConfig.channel;

                    pkgs =
                        if channel == "unstable" then
                            mkPkgs nixpkgs arch
                        else if channel == "stable" then
                            mkPkgs nixpkgs-stable arch
                        else
                            throw "Invalid channel '${channel}' in ${toString path}";
                in {
                    inherit arch channel pkgs;
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
                        };

                        modules = [
                            ./nix/hosts/${host}
                            inputs.sops-nix.nixosModules.sops
                            inputs.disko.nixosModules.disko
                            inputs.impermanence.nixosModules.impermanence
                            inputs.lanzaboote.nixosModules.lanzaboote
                            inputs.nvf.nixosModules.default
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
