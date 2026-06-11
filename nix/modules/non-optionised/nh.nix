{ pkgs, ... }: 
let
    directory_flake = "/home/meow/dots";
in {

    programs.nh = {
        enable = true;
	clean.enable = true;
	clean.extraArgs = "--keep-since 4d --keep 3";
	flake = "${directory_flake}";
    };
}
