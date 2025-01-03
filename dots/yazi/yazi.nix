{ config, inputs, lib, pkgs, ... }: {

    xdg.configFile = {
        "yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink ./yazi.toml;
        "yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink ./theme.toml;
    };

    programs.zsh = lib.mkIf config.programs.zsh.enable {
        initExtra = ''
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
        '';
        shellAliases = {
            lf = "yy";
            f = "yy";
            yazi = "yy";
        };
    };

    programs.yazi = {
        enable = true;
        package = inputs.yazi.packages.${pkgs.system}.default;
	    enableBashIntegration = config.programs.bash.enable;
	    enableZshIntegration = config.programs.zsh.enable;
    };

    home.packages = builtins.attrValues {
        inherit (pkgs)
	    fd
	    ffmpegthumbnailer
	    file
	    fzf
	    jq
	    poppler
	    ripgrep
	    unar
	    wl-clipboard
	    zoxide
        exiftool
	    ;
    };
}
