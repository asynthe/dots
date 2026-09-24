{
    description = "asynthe's system flake -- dendritic";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

        flake-parts.url = "github:hercules-ci/flake-parts";
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
        import-tree.url = "github:vic/import-tree";

        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        impermanence.url = "github:nix-community/impermanence";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        sops-nix.url = "github:Mic92/sops-nix";

        hyprland.url = "github:hyprwm/Hyprland";
        hyprland.inputs.nixpkgs.follows = "nixpkgs";

        hermes-agent.url = "github:NousResearch/hermes-agent";

        nixpkgs-wine.url = "github:nixos/nixpkgs/ad6fe71504ff652bd8b52839de83575d15a02c29";

        nix-citizen.url = "github:LovingMelody/nix-citizen";
        lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
        lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs:
        inputs.flake-parts.lib.mkFlake { inherit inputs; }
            (inputs.import-tree ./nix);
}
