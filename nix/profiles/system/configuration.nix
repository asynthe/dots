{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.system;
in {
    options.meta.system = {
        user = mkOption { type = str; };

        # TODO Should this be here?
        disk.device = mkOption { type = str; };

        type = mkOption {
            type = enum [ "laptop" "pc" "server" ];
            default = "server";
        };
    };
    config = lib.mkMerge [
        # Shared config
        {
            # Change sh for dash.
            environment.binsh = "${pkgs.dash}/bin/dash";
        }

        # Shared by PC and Laptop
        (mkIf (elem cfg.type [ "pc" "laptop" ]) {
            # This option is not yet added to Stable (24.05)
            # That is why is going to be commented out.
            hardware.graphics.enable = true;
        })

        # Laptop
        (mkIf (cfg.type == "laptop") {

            # Proper TTY for 4K laptop screen
            boot.kernelParams = [
                "video=3840x2400"
                #"video=2560x1600"
            ];

            # TODO Test different options
            services.thermald.enable = true;
            services.tlp.enable = true;
            #services.tlp = {
                #CPU_SCALING_GOVERNOR_ON_AC = "performance";
                #CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

                #CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                #CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

                #CPU_MIN_PERF_ON_AC = 0;
                #CPU_MAX_PERF_ON_AC = 100;
                #CPU_MIN_PERF_ON_BAT = 0;
                #CPU_MAX_PERF_ON_BAT = 20;

                #Optional helps save long term battery health
                #START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
                #STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
            #};

            # NOTE Conflicts with tlp
            #services.auto-cpufreq.enable = true;
            #services.auto-cpufreq.settings = {
                #battery = {
                    #governor = "powersave";
                    #turbo = "never";
                #};
                #charger = {
                    #governor = "performance";
                    #turbo = "auto";
                #};
            #};
        })

        # PC
        (mkIf (cfg.type == "pc") {
            # ...
        })

        # Server
        (mkIf (cfg.type == "server") {
            # ...
        })
    ];
}
