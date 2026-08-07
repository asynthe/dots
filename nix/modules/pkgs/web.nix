{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        hugo
        p7zip
    ];
}
