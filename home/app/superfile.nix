{ inputs, pkgs, ... }: {

    home.packages = with pkgs; [
        inputs.superfile.packages.${system}.default
    ];
}
