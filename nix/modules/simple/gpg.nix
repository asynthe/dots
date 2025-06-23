{ pkgs, ... }: {

    # I got it running with the next commands.
    # `pkill gpg-agent` (If gpg-agent is running)
    # `gpg-agent --pinentry-program=/home/user/.nix-profile/bin/pinentry-curses --daemon`
    programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
    };

    environment.systemPackages = with pkgs; [
        pass-wayland
    ];
}
