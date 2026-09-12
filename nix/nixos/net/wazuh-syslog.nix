# Ships this host's journal to the Wazuh manager's syslog listener. The manager
# itself lives in the fleet flake (~/git/flakes) on sarten; this is only the client.
{ ... }:
{
    flake.modules.nixos.wazuh-syslog = { config, lib, ... }: {
        options.sys.wazuh = {
            syslogTarget = lib.mkOption {
                type        = lib.types.str;
                default     = "sarten";
                description = "Host running the manager's syslog listener";
            };

            syslogPort = lib.mkOption {
                type        = lib.types.port;
                default     = 514;
                description = "UDP port the manager accepts syslog on";
            };
        };

        config = let cfg = config.sys.wazuh; in {
            services.rsyslogd = {
                enable = true;

                # journald stays the log store; this instance only forwards.
                defaultConfig = "";

                # UDP because that is the only 514 the compose file publishes.
                extraConfig = ''
                    module(load="imjournal" StateFile="imjournal.state")

                    *.* action(type="omfwd"
                               target="${cfg.syslogTarget}"
                               port="${toString cfg.syslogPort}"
                               protocol="udp"
                               template="RSYSLOG_SyslogProtocol23Format")
                '';
            };
        };
    };
}
