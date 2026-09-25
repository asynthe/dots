{ ... }:
{
    flake.modules.nixos.irc = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            irssi
            weechat
        ];
    };
}
