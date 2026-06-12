{ config, lib, pkgs,  ... }:
let
    # TODO Get user from main file or config
    user = "meow";
    cfg = config.sys.modules.vm;
in {
    options.sys.modules.vm = {
        enable = lib.mkEnableOption "Virtualisation";
    };

    config = lib.mkIf cfg.enable {

        # libvirt / QEMU
        users.users.${user}.extraGroups = [ "libvirtd" ];
        boot.extraModprobeConfig = "options kvm_intel nested=1";
        networking.firewall.trustedInterfaces = [ "virbr0" ];
        programs.virt-manager.enable = true;
        services.spice-vdagentd.enable = true;
        virtualisation.spiceUSBRedirection.enable = true;
        virtualisation.libvirtd = {
            enable = true;
            qemu.package = pkgs.qemu_kvm;
            qemu.runAsRoot = true;
            qemu.swtpm.enable = true; # tpm

            # Disable or try to skip vm wait
            onShutdown = "shutdown";
            shutdownTimeout = 10;
            parallelShutdown = 2;
        };

        # VMware
        services.xserver.videoDrivers = [ "vmware" ];
        virtualisation.vmware.guest.enable = true;

        environment.systemPackages = with pkgs; [
            dnsmasq
            guestfs-tools
            virtiofsd
        ];
    };
}
