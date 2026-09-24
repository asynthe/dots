{ config, ... }:
{
    flake.modules.darwin.host-m2 = { ... }: {
        imports = with config.flake.modules.darwin; [
            core
            auth
            homebrew
            neovim
            cli
            atuin
            fonts
            database
        ];

        networking.hostName      = "m2";
        networking.computerName  = "m2";
        networking.localHostName = "m2";

        nixpkgs.hostPlatform = "aarch64-darwin";
        system.stateVersion  = 6;

        sys.user = "meow";
    };
}
