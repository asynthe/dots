{ ... }:
{
    flake.modules.darwin.core = { config, pkgs, ... }: {
        nixpkgs.config.allowUnfree = true;

        # The Nix daemon here came from the official installer, not
        # nix-darwin -- leave it alone rather than fight it over nix.conf.
        nix.enable = false;

        system.primaryUser = config.sys.user;
        users.users.${config.sys.user}.home = "/Users/${config.sys.user}";

        programs.zsh.enable = true;

        environment.systemPackages = [
            # macOS ships openrsync, which lacks --info=progress2 -- the `cp`
            # alias in config/zsh/.zsh_aliases needs a real rsync ahead of it
            # on PATH.
            pkgs.rsync
        ];
    };
}
