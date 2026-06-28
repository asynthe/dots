{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.vm;
    impermanenceCfg = config.sys.disk.impermanence;
in {
    options.sys.modules.vm = {
        enable = lib.mkEnableOption "Virtualisation";
        gpu-passthrough = lib.mkEnableOption "GPU passthrough via VFIO";
        vmware = lib.mkEnableOption "VMware guest support";
    };

    config = lib.mkIf cfg.enable {

        # libvirt / QEMU
        networking.firewall.trustedInterfaces = [ "virbr0" ];
        programs.dconf.enable = true;
        programs.virt-manager.enable = true;
        services.spice-vdagentd.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "libvirtd" ];
        virtualisation.spiceUSBRedirection.enable = true;
        virtualisation.libvirtd = {
            enable = true;
            qemu.package = pkgs.qemu_kvm;
            qemu.swtpm.enable = true;
        };
        boot.extraModprobeConfig = "options kvm_intel nested=1"
            + lib.optionalString cfg.gpu-passthrough "\noptions vfio-pci ids=10de:28b8";

        # impermanence
        environment.persistence = lib.mkIf impermanenceCfg.enable {
            ${impermanenceCfg.folder}.directories = [
                "/var/lib/libvirt"

                # fix for swtpm permissions
                {
                    directory = "/var/lib/swtpm";
                    user = "tss";
                    group = "tss";
                    mode = "0750";
                }
                {
                    directory = "/var/lib/swtpm-localca";
                    user = "tss";
                    group = "tss";
                    mode = "0750";
                }
            ];
        };

        # GPU passthrough
        boot.kernelModules = lib.mkIf cfg.gpu-passthrough [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
        boot.kernelParams = lib.mkIf cfg.gpu-passthrough [ "intel_iommu=on" "iommu=pt" ];

        # VMware guest
        services.xserver.videoDrivers = lib.mkIf cfg.vmware [ "vmware" ];
        virtualisation.vmware.guest.enable = lib.mkIf cfg.vmware true;

        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
            dnsmasq
            guestfs-tools
            libguestfs
            spice
            spice-gtk
            spice-protocol
            spice-vdagent
            virtio-win
            virtiofsd
            win-spice
        ];
    };
}
