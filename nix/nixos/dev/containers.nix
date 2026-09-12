{ ... }:
{

    flake.modules.nixos.incus = { config, ... }: {
        virtualisation.incus.enable = true;
        networking.nftables.enable = true;
        users.users.${config.sys.user}.extraGroups = [ "incus-admin" ];
    };
}
