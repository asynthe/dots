{ ... }:
{
    flake.modules.nixos.tpm = { config, lib, ... }: {
        security.tpm2.enable = true;
        security.tpm2.pkcs11.enable = true;
        security.tpm2.tctiEnvironment.enable = true;
        users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "tss" ]; });
    };
}
