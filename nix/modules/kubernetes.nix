{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.kubernetes;
    impermanenceCfg = config.sys.disk.impermanence;
    kubeMasterIP = "127.0.0.1";
    kubeMasterHostname = "api.kube";
    kubeMasterAPIServerPort = 6443;
in {
    options.sys.modules.kubernetes = {
        enable = lib.mkEnableOption "Kubernetes";
    };

    config = lib.mkIf cfg.enable {
        networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

        environment.systemPackages = with pkgs; [
            kompose
            kubectl
            kubernetes
        ];

        services.kubernetes = {
            roles = [ "master" "node" ];
            masterAddress = kubeMasterHostname;
            apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
            easyCerts = true;
            apiserver = {
                securePort = kubeMasterAPIServerPort;
                advertiseAddress = kubeMasterIP;
            };
            addons.dns.enable = true;
            kubelet.extraOpts = "--fail-swap-on=false"; # if using swap
        };

        environment.persistence.${impermanenceCfg.folder}.directories = lib.mkIf impermanenceCfg.enable [
            "/var/lib/kubernetes"
            "/etc/kubernetes"
            "/var/lib/kubelet"
            "/var/lib/etcd"
            "/var/lib/cfssl"
        ];
    };
}
