{ pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [
        
        # Fun
	    figlet
	    lolcat
	    nhentai # ( ͡° ͜ʖ ͡°) 
	    peaclock tty-clock
	    pulsemixer # from pulseaudio
	    unimatrix
        asciiquarium-transparent
        bottom
        btop
        cli-visualizer
        cpu-x
        pipes-rs

        # Fetch
        pfetch
        fastfetch
        neofetch
        starfetch

        # Other
        pkgs-stable.mapscii #mapscii
    ];
}
