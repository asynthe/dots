{ lib, ... }:
{
    options.sys.user = lib.mkOption {
        type        = lib.types.str;
        description = "Primary system user";
    };
}
