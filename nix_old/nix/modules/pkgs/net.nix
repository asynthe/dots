{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        nethogs
        bandwhich
    ];
}
