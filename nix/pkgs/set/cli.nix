{ pkgs, pkgs-stable, ... }: {

    environment.systemPackages = with pkgs; [
        
        # Fun
	    figlet
	    lolcat
	    nhentai # ( ͡° ͜ʖ ͡°) 
	    peaclock tty-clock
	    unimatrix
        asciiquarium-transparent
        bottom
        btop
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
