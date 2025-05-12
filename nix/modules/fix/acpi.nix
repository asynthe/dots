{ config, pkgs, ... }: {

    services.acpid.enable = true;
    environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
	    acpi
	    ;
    };
}
