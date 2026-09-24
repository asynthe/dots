{ ... }:
{
    flake.modules.nixos.share = { config, lib, ... }: {
        options.sys.share = {
            members = lib.mkOption {
                type        = lib.types.listOf lib.types.str;
                default     = config.sys.admins;
                description = "Accounts in the share group; others join with `groups` in auth.nix";
            };

            mounts = lib.mkOption {
                default     = {};
                example     = {
                    "/home/kazu/music" = "/home/meow/archive/media/music";
                    "/home/kazu/roms"  = { source = "/home/meow/archive/roms"; writable = false; };
                };
                description = ''
                    mountpoint -> source, or -> { source, writable }. Bind
                    mounts, so the path is resolved once at mount time and
                    reaching it never walks the source's parents. A writable
                    source is opened to the share group by ACL; a read-only one
                    is left as it is, readable and nothing more.
                '';
                type = lib.types.attrsOf (lib.types.coercedTo
                    lib.types.str
                    (source: { inherit source; })
                    (lib.types.submodule {
                        options.source = lib.mkOption {
                            type        = lib.types.str;
                            description = "Directory to publish";
                        };
                        options.writable = lib.mkOption {
                            type        = lib.types.bool;
                            default     = true;
                            description = "Whether the share group may write, not only read";
                        };
                    }));
            };
        };

        config = {
            users.groups.share.members = config.sys.share.members;

            fileSystems = lib.mapAttrs
                (_: m: {
                    device  = m.source;
                    fsType  = "none";
                    options = [ "bind" "nofail" ];
                })
                config.sys.share.mounts;

            systemd.tmpfiles.rules = lib.mapAttrsToList
                (_: m: "A+ ${m.source} - - - - d:g:share:rwX,g:share:rwX")
                (lib.filterAttrs (_: m: m.writable) config.sys.share.mounts);
        };
    };
}
