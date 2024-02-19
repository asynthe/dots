{
  description = "asynthe's system flake";

outputs = inputs @ {
  self,
  nixpkgs,
  home-manager,
  musnix,
  sops-nix,
  impermanence,
  #hyprland,
  #nix-darwin,
  #nixpkgs-wayland,
  #nixos-06cb-009a-fingerprint-sensor,
  #nix-gaming,
  #nix-on-droid,
  ...
	}: let

  # Linux / Home
  username = "asynthe";
  hostname = "thinknya";

  # Darwin
  username_mac = "benjamindunstan";
  hostname_mac = "Benjis-Macbook";

  # pkgs
  linux_64 = "x86_64-linux";
  apple_silicon = "aarch64-darwin";
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  
  in {

nixosConfigurations = {

server = nixpkgs.lib.nixosSystem {
  system = "${hostname}";
  specialArgs = { inherit
    username
    hostname
    inputs
    ;
  };
  modules = [
    ./hosts/linux/server
    impermanence.nixosModules.impermanence
  ];
};

thinkpad = nixpkgs.lib.nixosSystem {
  system = "thinkpad";
  specialArgs = { inherit
    inputs
    ;
  };
  modules = [
    ./hosts/thinkpad
    musnix.nixosModules.musnix
    impermanence.nixosModules.impermanence
    # Home Manager as Module goes here !
    ];
  };
};

homeConfigurations = {
  ben = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {inherit
      inputs
      ;
    };
    modules = [ ./modules/home/users/ben ];
  };
};

#darwinConfigurations = {
  #${hostname_mac} = nix-darwin.lib.darwinSystem {
    #system = "${apple_silicon}";
    #specialArgs = {inherit username_mac inputs;};
      #modules = [ ./hosts/macos ];
  #};
#};

};
 inputs = {

nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable.
#nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11"; # Stable.

home-manager = {
  url = "github:nix-community/home-manager"; # Follows nixpkgs unstable.
  #url = "github:nix-community/home-manager/release-23.11"; # Follows nixpkgs stable.
  inputs.nixpkgs.follows = "nixpkgs"; 
  # Follows the nixpkgs channel defined before, 
  # to avoid different versions of nixpkgs deps problems.
};

impermanence.url = "github:nix-community/impermanence";
sops-nix.url = "github:Mic92/sops-nix";
musnix.url = "github:musnix/musnix";

#nil.url = "github:oxalica/nil";
#nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
#nix-gaming.url = "github:fufexan/nix-gaming";
#helix.url = "github:helix-editor/helix/23.05";
#hyprland.url = "github:hyprwm/Hyprland";
#rust-overlay.url = "github:oxalica/rust-overlay";

#nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
#nix-darwin = {
  #url = "github:lnl7/nix-darwin";
  #inputs.nixpkgs.follows = "nixpkgs-darwin";
#};

#nix-on-droid = {
  #url = "github:t184256/nix-on-droid/release-23.05";
  #inputs.nixpkgs.follows = "nixpkgs-stable";
  #};

#nixos-06cb-009a-fingerprint-sensor = {
  #url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
  #inputs.nixpkgs.follows = "nixpkgs";
#};

};
}

#nixOnDroidConfigurations.default =
  #nix-on-droid.lib.nixOnDroidConfiguration {
    #modules = [
      #./nix/nix-on-droid
    #];
  #};
