{
    imports = [
        
        ../modules/pkgs_minimal.nix
        ../modules/fonts.nix

        # Apps
	../modules/app/alacritty.nix
        ../modules/app/android.nix # adb + waydroid.
        #../modules/app/bash.nix # bash shell.
	../modules/app/bat.nix
	#../modules/app/emacs.nix
	../modules/app/eza.nix
        ../modules/app/git.nix
        ../modules/app/gpg.nix
        ../modules/app/lf.nix
        #../modules/app/mako.nix
	#../modules/app/mpd.nix
	../modules/app/mpv.nix
	#../modules/app/obs.nix
	#../modules/app/social.nix
        ../modules/app/ssh.nix
        ../modules/app/starship.nix
        ../modules/app/tmux.nix
        #../modules/app/wofi.nix
        ../modules/app/yazi.nix
        ../modules/app/zathura.nix
        ../modules/app/zoxide.nix
        ../modules/app/zsh.nix

        # Dev
        ../modules/dev/ai.nix
        #../modules/dev/assembly.nix
        ../modules/dev/latex.nix
        #../modules/dev/python.nix # Managed by kali's apt for now.

        # System
        ../modules/sys/nix_settings.nix
    ];
}
