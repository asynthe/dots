{ inputs, ... }:
{
    flake.modules.nixos.hermes = { config, lib, pkgs, ... }: {
        imports = [ inputs.hermes-agent.nixosModules.default ];

        options.sys.hermes = {
            model = lib.mkOption {
                type        = lib.types.str;
                default     = "claude-sonnet-5";
                description = "Default model id (provider comes from config.yaml's model.provider)";
            };

            env = lib.mkOption {
                type        = lib.types.attrsOf lib.types.str;
                default     = {
                    CLAUDE_CODE_OAUTH_TOKEN = "hermes/CLAUDE_CODE_OAUTH_TOKEN";
                    # Unset SIGNAL_ALLOWED_USERS lets anyone DM the bot.
                    SIGNAL_ACCOUNT          = "hermes/SIGNAL_ACCOUNT";
                    SIGNAL_ALLOWED_USERS    = "hermes/SIGNAL_ALLOWED_USERS";
                    SIGNAL_HOME_CHANNEL     = "hermes/SIGNAL_HOME_CHANNEL";
                };
                description = "Env vars mapped to their sops key paths; `{}` defers auth to `hermes auth`";
            };

            signal = lib.mkOption {
                type        = lib.types.bool;
                default     = true;
                description = "Run a signal-cli HTTP daemon on 127.0.0.1:8080 for the Signal gateway";
            };

            dashboard = lib.mkEnableOption "the browser admin panel and /api sockets";

            bind = lib.mkOption {
                type        = lib.types.str;
                default     = "127.0.0.1";
                description = "Address the dashboard binds to; anything but loopback turns on its auth gate";
            };

            waitForHost = lib.mkOption {
                type        = lib.types.bool;
                default     = false;
                description = "Poll until `bind` resolves before binding, for names that appear late (tailscale)";
            };
        };

        config = let
            env    = config.sys.hermes.env;
            hasEnv = env != { };
        in {
            sops.secrets = lib.mapAttrs' (name: key:
                lib.nameValuePair "hermes-${name}" { inherit key; }
            ) env;

            sops.templates = lib.mkIf hasEnv {
                hermes-env.content = lib.concatStringsSep "\n" (
                    lib.mapAttrsToList
                        (name: _: "${name}=${config.sops.placeholder."hermes-${name}"}")
                        env
                );
            };

            services.hermes-agent = {
                enable              = true;
                addToSystemPackages = true;
                environmentFiles    =
                    lib.optional hasEnv config.sops.templates.hermes-env.path;

                settings.model.default = config.sys.hermes.model;

                environment = lib.mkIf config.sys.hermes.signal {
                    SIGNAL_HTTP_URL = "http://127.0.0.1:8080";
                };

                backend.mode    = if config.sys.hermes.dashboard then "dashboard" else "none";
                backend.host    = config.sys.hermes.bind;
                backend.waitFor = lib.mkIf config.sys.hermes.waitForHost "hostname";
            };

            # First run needs linking to the phone (docs/ai.md).
            systemd.services.signal-cli = lib.mkIf config.sys.hermes.signal {
                description = "signal-cli HTTP daemon for Hermes";
                wantedBy    = [ "multi-user.target" ];
                before      = [ "hermes-agent.service" ];
                after       = [ "network-online.target" ];
                wants       = [ "network-online.target" ];
                serviceConfig = {
                    User       = "hermes";
                    Group      = "hermes";
                    ExecStart  = "${pkgs.signal-cli}/bin/signal-cli --config /var/lib/hermes/signal-cli daemon --http 127.0.0.1:8080 --receive-mode on-connection";
                    Restart    = "on-failure";
                    RestartSec = 10;
                };
            };
            environment.systemPackages = lib.mkIf config.sys.hermes.signal [ pkgs.signal-cli ];

            users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "hermes" ]; });

            environment.persistence.${config.sys.impermanence.folder}.directories =
                lib.mkIf config.sys.impermanence.enable [
                    { directory = "/var/lib/hermes"; user = "hermes"; group = "hermes"; mode = "2770"; }
                ];
        };
    };
}
