{
    description = "asynthe's system flake";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

        disko.inputs.nixpkgs.follows = "nixpkgs";
        disko.url = "github:nix-community/disko";
        impermanence.url = "github:nix-community/impermanence";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        sops-nix.url = "github:Mic92/sops-nix";

        hyprland.url = "github:hyprwm/Hyprland";
        hyprland.inputs.nixpkgs.follows = "nixpkgs";

        # Testing
        nix-citizen.url = "github:LovingMelody/nix-citizen";
        lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
        lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = {
        self,
        nixpkgs,
        nixpkgs-stable,
        lanzaboote,
        nix-citizen,
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

            mkPkgs = nixpkgsInput: arch:
                import nixpkgsInput {
                    system = arch;
                    config = {
                        allowUnfree = true;
                        android_sdk.accept_license = true;
                    };
                    overlays = [
                        # flannel 0.28.6 has a wrong hash in nixpkgs; actual hash from upstream
                        (final: prev: {
                            flannel = prev.flannel.overrideAttrs (old: {
                                src = old.src.overrideAttrs (_: {
                                    outputHash = "sha256-sqpsUAKBza96AMQMUCG94KOht5ExnHRLR7eGna3m3Xg=";
                                });
                            });
                        })
                    ];
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
                            inputs.nix-citizen.nixosModules.default
                        ];
                    };
                };

        in {
            nixosConfigurations =
                builtins.listToAttrs (map mkHost hostDirs);
        };
}
