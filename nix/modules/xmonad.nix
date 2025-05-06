{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        xmonad
        xmonad-with-packages
        xmobar
        dmenu
        nitrogen
        nsxiv
        xclip
        xorg.xinit
        xorg.xprop
        picom-jonaburg
        xargs
        xlsclients
    ];
}
