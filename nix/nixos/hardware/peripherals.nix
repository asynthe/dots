{ ... }:
{
    flake.modules.nixos.audio = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            alsa-utils
            pulsemixer
            wiremix
        ];

        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            audio.enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
            wireplumber.enable = true;
        };
    };

    flake.modules.nixos.bluetooth = { config, lib, pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            bluetuith
            bluez-tools
        ];

        services.blueman.enable = true;
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;

        environment.persistence.${config.sys.impermanence.folder}.directories =
            lib.mkIf config.sys.impermanence.enable [ "/var/lib/bluetooth" ];

        # TODO hardware.bluetooth.settings to disable hands-free mode, test with the nothing earphones
    };

    # PS5 controller. Pairs over bluetooth, so import `bluetooth` too.
    flake.modules.nixos.controller = { config, pkgs, ... }: {
        hardware.xpadneo.enable = true;
        users.extraGroups.input.members = [ config.sys.user ];
        environment.systemPackages = with pkgs; [
            dualsensectl
        ];
    };

    flake.modules.nixos.colord = { ... }: {
        services.colord.enable = true;
    };

    flake.modules.nixos.android = { config, pkgs, ... }: {
        #programs.nix-ld.enable = true;
        #programs.nix-ld.libraries = [ pkgs.libGL pkgs.glib ];

        #virtualisation.waydroid.enable = true;
        #services.gvfs.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "kvm" "adbusers" ];
        environment.systemPackages = with pkgs; [
            #androidsdk
            android-tools
            #android-studio
            #jmtpfs
            scrcpy
        ];
    };
}
