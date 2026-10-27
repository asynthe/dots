{ ... }:
{
    flake.modules.nixos.boot-silent = { ... }: {
        boot.consoleLogLevel = 0;
        boot.kernelParams = [
            "splash"
            "quiet"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
        ];
    };
}
