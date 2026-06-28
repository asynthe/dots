{ config, ... }:
let
    impermanenceCfg = config.sys.disk.impermanence;
in {
    config = {
        time.hardwareClockInLocaltime = true;
        environment.persistence.${impermanenceCfg.folder}.files = [ "/etc/adjtime" ];
    };
}
