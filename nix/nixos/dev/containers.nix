{ ... }:
{

    flake.modules.nixos.incus = { config, lib, ... }: {
        virtualisation.incus.enable = true;
        networking.nftables.enable = true;
        users.users = lib.genAttrs config.sys.admins (_: { extraGroups = [ "incus-admin" ]; });
    };
}
