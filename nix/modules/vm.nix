{ config, lib, pkgs, ... }:
let
    cfg = config.sys.modules.vm;
in {
    options.sys.modules.vm = {
        enable = lib.mkEnableOption "Virtualisation";
        gpu-passthrough = lib.mkEnableOption "GPU passthrough via VFIO";
        vmware = lib.mkEnableOption "VMware guest support";
    };

    config = lib.mkIf cfg.enable {

        # libvirt / QEMU
        users.users.${config.sys.user}.extraGroups = [ "libvirtd" ];
        boot.extraModprobeConfig = "options kvm_intel nested=1"
            + lib.optionalString cfg.gpu-passthrough "\noptions vfio-pci ids=10de:28b8";
        networking.firewall.trustedInterfaces = [ "virbr0" ];
        programs.virt-manager.enable = true;
        services.spice-vdagentd.enable = true;
        virtualisation.spiceUSBRedirection.enable = true;
        virtualisation.libvirtd = {
            enable = true;
            qemu.package = pkgs.qemu_kvm;
            qemu.runAsRoot = true;
            qemu.swtpm.enable = true; # TPM

            # Disable or try to skip vm wait
            onShutdown = "shutdown";
            shutdownTimeout = 10;
            parallelShutdown = 2;
        };

        # GPU passthrough
        boot.kernelModules = lib.mkIf cfg.gpu-passthrough [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
        boot.kernelParams = lib.mkIf cfg.gpu-passthrough [ "intel_iommu=on" "iommu=pt" ];


        # VMware guest
        services.xserver.videoDrivers = lib.mkIf cfg.vmware [ "vmware" ];
        virtualisation.vmware.guest.enable = lib.mkIf cfg.vmware true;

        environment.systemPackages = with pkgs; [
            dnsmasq
            guestfs-tools
            virtiofsd
            gvfs
        ];
    };
}
