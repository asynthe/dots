{ inputs, ... }:
{
    flake.modules.nixos.claude-code = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.claude-code ];
    };

    flake.modules.nixos.opencode = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.opencode ];
    };

    flake.modules.nixos.hermes = { config, lib, ... }: {
        imports = [ inputs.hermes-agent.nixosModules.default ];

        options.sys.hermes = {
            model = lib.mkOption {
                type        = lib.types.str;
                default     = "anthropic/claude-opus-4.6";
                description = "Default model id, `<provider>/<model>`";
            };

            env = lib.mkOption {
                type        = lib.types.attrsOf lib.types.str;
                default     = { CLAUDE_CODE_OAUTH_TOKEN = "hermes/CLAUDE_CODE_OAUTH_TOKEN"; };
                description = "Provider env vars mapped to their sops key paths; `{}` defers auth to `hermes auth`";
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

                backend.mode    = if config.sys.hermes.dashboard then "dashboard" else "none";
                backend.host    = config.sys.hermes.bind;
                backend.waitFor = lib.mkIf config.sys.hermes.waitForHost "hostname";
            };

            users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "hermes" ]; });

            environment.persistence.${config.sys.impermanence.folder}.directories =
                lib.mkIf config.sys.impermanence.enable [
                    { directory = "/var/lib/hermes"; user = "hermes"; group = "hermes"; mode = "2770"; }
                ];
        };
    };
}
