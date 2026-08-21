{ ... }:
{
    flake.modules.nixos.docker = { config, ... }: {
        virtualisation.docker.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "docker" ];
        # TODO derive from the host's root filesystem instead of hardcoding
        virtualisation.docker.storageDriver = "btrfs";
    };

    flake.modules.nixos.incus = { config, ... }: {
        virtualisation.incus.enable = true;
        networking.nftables.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "incus-admin" ];
    };

    # Replaces services.kubernetes (fragile easyCerts); same tool as the Proxmox
    # lab (infra-lach/terraform/k3s)
    flake.modules.nixos.k3s = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ kubectl kubernetes-helm ];

        services.k3s = {
            enable = true;
            role = "server";
            extraFlags = toString [ "--write-kubeconfig-mode=644" ];
        };
    };

    # Fragile easyCerts setup, never came up cleanly -- prefer `k3s`.
    flake.modules.nixos.kubernetes = { config, lib, pkgs, ... }:
    let
        kubeMasterIP = "127.0.0.1";
        kubeMasterHostname = "api.kube";
        kubeMasterAPIServerPort = 6443;
    in {
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

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [
                "/var/lib/kubernetes"
                "/etc/kubernetes"
                "/var/lib/kubelet"
                "/var/lib/etcd"
                "/var/lib/cfssl"
            ];
    };
}
