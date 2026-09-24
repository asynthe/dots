{ ... }:
{
    flake.modules.darwin.core = { lib, ... }: {
        options.sys.user = lib.mkOption {
            type        = lib.types.str;
            description = ''
                macOS account nix-darwin treats as system.primaryUser. Must
                already exist -- nix-darwin configures an account, it does not
                create one.
            '';
        };
    };
}
