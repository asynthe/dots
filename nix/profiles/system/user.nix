{ config, lib, pkgs, ... }: 
with lib; with types;
let
    cfg = config.meta.system;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.system.users = mkOption {
        type = str;
        default = config.meta.system.type;
        description = "Set up the system users.";
    };

    # ───────────────────────── Configuration ─────────────────────────
    config = mkMerge [

        # KEEP HERE FOR SOPS-FICATION
        # Laptop configuration
       #(mkIf (cfg.users == "laptop") {
       #    sops.secrets."password/thinkpad".neededForUsers = true;
       #    users.mutableUsers = false; # Required for passwords set by sops.
       #    users.users.${config.meta.system.user} = {
       #        shell = pkgs.zsh;
       #        isNormalUser = true;
       #        description = "にゃ！";
	   #        hashedPasswordFile = config.sops.secrets."password/thinkpad".path;
       #        extraGroups = [ "audio" "networkmanager" "input" "wheel" ];
       #    };
       #    programs.zsh.enable = true;
       #    security.sudo.extraConfig = ''
       #      Defaults timestamp_timeout=120 # Ask for password every 2 hours.
       #    '';
       #})

        (mkIf (cfg.users == "laptop") {

            # SSH for nixos-anywhere
            services.openssh.enable = mkForce true;
            users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY8tUQ59AvWkt0pTSMz2bf3O7emcO37IaA8vZCnXisk bendunstan@protonmail.com" ];     

            users.users.${config.meta.system.user} = {
                shell = pkgs.zsh;
                isNormalUser = true;
                description = "にゃ！";
                initialPassword = "meows123";
                extraGroups = [ "audio" "networkmanager" "input" "wheel" ];
            };
            programs.zsh.enable = true;
            security.sudo.extraConfig = ''
              Defaults timestamp_timeout=120 # Ask for password every 2 hours.
            '';
        })

        # Server configuration
        (mkIf (cfg.users == "server") {

            # SSH for nixos-anywhere
            services.openssh.enable = mkForce true;
            users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY8tUQ59AvWkt0pTSMz2bf3O7emcO37IaA8vZCnXisk bendunstan@protonmail.com" ];

            users.users.data = {
	            description = "User that can modify data";
                initialPassword = "meows123";
                isNormalUser = true;
	            extraGroups = [ "networkmanager" "wheel" "shared" ];

                # Authorized SSH key.
                openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY8tUQ59AvWkt0pTSMz2bf3O7emcO37IaA8vZCnXisk bendunstan@protonmail.com" ];
	        };
        })
    ]; 
}
