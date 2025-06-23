{ config, lib, ... }: 
with lib; with types;
let
    cfg = config.meta.services.docker;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.docker.enable = mkEnableOption "Enable and set up Docker.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        # ─────────────────────────────────────────────────────────────────
        # Beware that docker group membership is equivalent to being root!
        # See more at https://github.com/moby/moby/issues/9976
        # See also Rootless mode (below).
        # ─────────────────────────────────────────────────────────────────

        users.users.${config.meta.system.user}.extraGroups = [ "docker" ];
        virtualisation.docker = {
            enable = true;
            #storageDriver = # mkIf.system.configuration.filesystem = "btrfs" then "btrfs";
            #rootless = { # Rootless mode
                #enable = true;
                #setSocketVariable = true;
            #};
        };

        # ADD options for podman
        #virtualisation.podman = {
            #enable = true;
            #dockerCompat = true; # `docker` alias for podman.
            #defaultNetwork.settings.dns_enabled = true; # Required so podman-composed containers to be able to talk to each other.
        #};
    };
}
