{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.k3s;
in {
    options.sys.modules.k3s = {
        enable = lib.mkEnableOption "k3s (lightweight Kubernetes)";
    };

    # Replaces services.kubernetes (fragile easyCerts); same tool as the Proxmox lab (infra-lach/terraform/k3s)
    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ kubectl kubernetes-helm ];

        services.k3s = {
            enable = true;
            role = "server";
            extraFlags = toString [ "--write-kubeconfig-mode=644" ];
        };
    };
}
