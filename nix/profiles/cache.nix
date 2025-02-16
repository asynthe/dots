{ config, lib, ... }:
with lib; with types;  
let
    cfg = config.meta.cache;
in {
    options.meta.cache = {
        nvidia = mkEnableOption "Enable cuda mantainers cachix repository.";
        #hyprland = mkEnableOption "";
    };
    
    config = {
        nix.settings = mkIf cfg.nvidia {
            substituters = [ "https://cuda-maintainers.cachix.org" ];
            trusted-public-keys = [ "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" ];
        };
    };
}
