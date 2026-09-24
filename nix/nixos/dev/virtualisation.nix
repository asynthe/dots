{ ... }:
{
    flake.modules.nixos.virtualisation = { config, lib, pkgs, ... }: {

        networking.firewall.trustedInterfaces = [
            "virbr0"
            "virbr1"
        ];
        programs.dconf.enable = true;
        programs.virt-manager.enable = true;
        services.spice-vdagentd.enable = true;
        users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "libvirtd" ]; });
        virtualisation.spiceUSBRedirection.enable = true;
        virtualisation.libvirtd = {
            enable = true;
            qemu.package = pkgs.qemu_kvm;
            qemu.swtpm.enable = true;
        };
        boot.extraModprobeConfig = "options kvm_intel nested=1";

        systemd.services.libvirt-networks-no-autostart = {
            description = "Disable autostart on libvirt networks";
            after = [ "libvirtd.service" ];
            requires = [ "libvirtd.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };
            script = let
                virsh = "${config.virtualisation.libvirtd.package}/bin/virsh -c qemu:///system";
            in ''
                for net in $(${virsh} net-list --all --name); do
                    ${virsh} net-autostart --disable "$net" || true
                    ${virsh} net-destroy "$net" || true
                done
            '';
        };

        environment.persistence = lib.mkIf config.sys.impermanence.enable {
            ${config.sys.impermanence.folder}.directories = [
                "/var/lib/libvirt"

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

        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
            dnsmasq
            guestfs-tools
            libguestfs
            spice spice-gtk
            spice-protocol
            spice-vdagent
            virtio-win
            virtiofsd
            win-spice
        ];
    };

    flake.modules.nixos.vfio = { ... }: {
        boot.extraModprobeConfig = "options vfio-pci ids=10de:28b8";
        boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
        boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    };

    flake.modules.nixos.vmware-guest = { ... }: {
        services.xserver.videoDrivers = [ "vmware" ];
        virtualisation.vmware.guest.enable = true;
    };
}
