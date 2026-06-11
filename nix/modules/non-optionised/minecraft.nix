{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [
	fabric-installer
	optifine
        prismlauncher
    ];
    
    services.minecraft-server = {
        enable = true;
	eula = true;
	package = pkgs.papermc;
    };
}
