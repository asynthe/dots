{
    description = "asynthe's system flake";
    inputs = {

        # Main Inputs
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
        home-manager.url = "github:nix-community/home-manager";
	    home-manager.inputs.nixpkgs.follows = "nixpkgs"; 

	    # Other
	    nix-darwin.url = "github:/lnl7/nix-darwin/master";
	    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        disko.url = "github:nix-community/disko";
        ghostty.url = "github:ghostty-org/ghostty";
        impermanence.url = "github:nix-community/impermanence";
        lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
        lanzaboote.url = "github:nix-community/lanzaboote";
        musnix.url = "github:musnix/musnix";
        sops-nix.url = "github:Mic92/sops-nix";
        stylix.url = "github:danth/stylix";
        superfile.url = "github:yorukot/superfile";
        wezterm.url = "github:wez/wezterm?dir=nix";
        yazi.url = "github:sxyazi/yazi";

        # Apps
	    nixvim = {
            url = "github:nix-community/nixvim";
	        #inputs.nixpkgs.follows = "nixpkgs";
        };
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        Hyprspace = {
            url = "github:KZDKM/Hyprspace";
            inputs.hyprland.follows = "hyprland";
        };
        swww.url = "github:LGFae/swww";
    };

    outputs = {

        # Main
        self,
        nixpkgs,
        nixpkgs-stable,
        home-manager,

        # Other
	    nix-darwin,
        nixos-hardware,
        nixos-wsl,
        disko,
        impermanence,
        lanzaboote,
        musnix,
        sops-nix,
        stylix,

        # Apps
	    nixvim,
        ghostty,
        hyprland,
        superfile,
        swww,
        wezterm,
        yazi,
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
        # Custom packages
        # `nix-build`, `nix shell nixpkgs#<custompkg>`, etc.
        #packages = forAllSystems (system: import ./other/pkgs nixpkgs.legacyPackage.${system});

        # Formatter for nix files -> `nix fmt`
        # Options: `alejandra`, `nixpkgs-fmt`
        #formatter = forAllSystems (system: nixpkgs.legacyPackage.${system}.alejandra);

        # Custom packages and overlays (modifications)
        #overlays = import ./other/overlays {inherit inputs;};

        # Reusable modules to export, nixos and home manager
        # Usually stuff you would upstream into nixpkgs and home-manager ???
        #nixosModules = import ./modules/nixos;
        #homeManagerModules = import ./modules/home-manager;

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

            # Thinkpad
            #thinkpad = nixpkgs.lib.nixosSystem {
                #specialArgs = { inherit inputs outputs pkgs-stable; };
                #modules = [
                    #./nix/hosts/thinkpad
                    #nixos-hardware.nixosModules.lenovo-thinkpad-t480
	                #sops-nix.nixosModules.sops
                    #disko.nixosModules.disko
                    #impermanence.nixosModules.impermanence
                    #lanzaboote.nixosModules.lanzaboote
                    #musnix.nixosModules.musnix
                #];
            #};

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
        homeConfigurations = {

            # meow
            meow = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.x86_64-linux; # Required by Home Manager.
                extraSpecialArgs = { inherit inputs outputs pkgs-stable;
	                user = "meow";
                };
                modules = [ 
	                ./home/user/meow 
	                nixvim.homeManagerModules.nixvim
	                sops-nix.homeManagerModules.sops
                    hyprland.homeManagerModules.default
                    stylix.homeManagerModules.stylix
	            ];
            };
            
            # missingno
            #missingno = home-manager.lib.homeManagerConfiguration {
                #pkgs = nixpkgs.legacyPackages.x86_64-linux;
	            #extraSpecialArgs = {
                    #inherit pkgs;
                    #inherit pkgs-stable inputs;
	                    #user = "missingno"
                    #;
	            #};
	            #modules = [
	                #./home/missingno
	                #nixvim.homeManagerModules.nixvim
                    #stylix.homeManagerModules.stylix
	            #];
            #};
        };
    };
}
