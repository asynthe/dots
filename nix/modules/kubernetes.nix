{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.kubernetes;
in {
    options.sys.modules.kubernetes = {
        enable = lib.mkEnableOption "Kubernetes";
    };

    config = lib.mkIf cfg.enable {
        services.kubernetes = {
            roles = [ "master" "node" ]; # single node Kubernetes cluster
            masterAddress = "localhost";
            apiserver.enable = true;
            controllerManager.enable = true;
            scheduler.enable = true;
            addonManager.enable = true;
            proxy.enable = true;
            flannel.enable = true;
        };
    };
}
