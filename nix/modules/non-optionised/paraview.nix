{ pkgs, ... }: {

    environment.systemPackages = with pkgs; [
        paraview
    ];
}
