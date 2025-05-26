{
    description = "asynthe's system flake";
    inputs = {

        # nixpkgs
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

	    # Other
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        disko.url = "github:nix-community/disko";
        impermanence.url = "github:nix-community/impermanence";
        lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
        lanzaboote.url = "github:nix-community/lanzaboote";
        musnix.url = "github:musnix/musnix";
        sops-nix.url = "github:Mic92/sops-nix";

        # Apps
        swww.url = "github:LGFae/swww";
	    #nixvim = {
            #url = "github:nix-community/nixvim";
	        #inputs.nixpkgs.follows = "nixpkgs";
        #};
    };

    outputs = {

        # Main
        self,
        nixpkgs,
        nixpkgs-stable,

        # Other
        nixos-hardware,
        nixos-wsl,
        disko,
        impermanence,
        lanzaboote,
        musnix,
        sops-nix,

        # Apps
	    #nixvim,
        swww,
        ...
    
    #}: let
	    #system = "x86_64-linux";
        #pkgs = nixpkgs.legacyPackages.${system};
        #pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    
    } @ inputs: let inherit (self) outputs;

        # Supported systems
        systems = [
            "x86_64-linux"
            "i686-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
        ];

        # Attribute -> calling a function you call to it passing each system as an argument.
        forAllSystems = nixpkgs.lib.genAttrs systems;
        
        #pkgs = nixpkgs.legacyPackages.${system};
	    system = "x86_64-linux";
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};

    in {
        # NixOS configurations
        nixosConfigurations = {

            # Raider
            raider = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit inputs outputs pkgs-stable; };
                modules = [
                    ./nix/hosts/raider
	                sops-nix.nixosModules.sops
                    disko.nixosModules.disko
                    impermanence.nixosModules.impermanence
                    lanzaboote.nixosModules.lanzaboote
                    musnix.nixosModules.musnix
                ];
            };

	        # Server
            #server = nixpkgs-stable.lib.nixosSystem {
                #specialArgs = { inherit inputs outputs pkgs-stable; };
                #modules = [
                    #./hosts/server
	                #sops-nix.nixosModules.sops
                    #disko.nixosModules.disko
                    #impermanence.nixosModules.impermanence
                    #lanzaboote.nixosModules.lanzaboote
                #];
            #};

            # WSL
            wsl = nixpkgs.lib.nixosSystem {
	            specialArgs = { inherit inputs outputs pkgs-stable; };
		        modules = [
		            ./nix/hosts/wsl
	                sops-nix.nixosModules.sops
                    disko.nixosModules.disko
                    impermanence.nixosModules.impermanence
                    lanzaboote.nixosModules.lanzaboote
                    musnix.nixosModules.musnix
		            nixos-wsl.nixosModules.default
                ];
	        };
        };

        # Home Manager configurations
        #homeConfigurations = {

            # meow
            #meow = home-manager.lib.homeManagerConfiguration {
                #pkgs = nixpkgs.legacyPackages.x86_64-linux; # Required by Home Manager.
                #extraSpecialArgs = { inherit inputs outputs pkgs-stable;
	                #user = "meow";
                #};
                #modules = [ 
	                #./nix/pkgs/home/meow 
	                #nixvim.homeManagerModules.nixvim
	                #sops-nix.homeManagerModules.sops
	            #];
            #};
        #};
    };
}
