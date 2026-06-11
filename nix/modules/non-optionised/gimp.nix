{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        gimp-with-plugins
    ];
}
