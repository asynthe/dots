{ pkgs, ... }: {
    home.packages = builtins.attrValues {
        inherit (pkgs)

            # DevOps
            #ollama
            #pulumi
            opentofu #terraform
            ansible

            # Assembly
            nasm nasmfmt
            yasm

            # Reverse engineering / Disassemblers
            #ghidra-bin #ghidra
            #radare2
            #hopper

            # Nix
            colmena
            deploy-rs
            #nixops_unstable #nixops
            #nixfmt
            alejandra

            # Tools
	        hyperfine
	        imagemagickBig
	        img2pdf
	        libqalculate
            cmus # Music player
            ffmpeg
            mediainfo # Video/audio metadata
            #meshlab #f3d #fstl # 3D files
            ripgrep
            sox
            tectonic # LaTeX Engine
            tesseract #easyocr # OCR

            # System
            ethtool
            iftop # Network monitoring
            inxi
            iotop # IO monitoring
            lm_sensors # for `sensors` command
            lshw # List hardware details
            lsof # List open files
            ltrace # Library call monitoring
            parted
            pciutils # lspci
            powershell
            strace # System call monitoring
            sysstat
            usbutils # lsusb

            # Networking
            nethogs
            mtr # A network diagnostic tool
            iperf3
            dnsutils # `dig` + `nslookup`
            ldns # replacement of `dig`, it provide the command `drill`
            ipcalc # it is a calculator for the IPv4/v6 addresses
            #inetutils
            dnsmasq
            traceroute
            filezilla
            dig
            netcat-openbsd #netcat #netcat-gnu
            socat #websocat
            putty

            # IRC
            weechat

	        # Fun
	        cli-visualizer
            cpu-x
	        figlet
	        lolcat
	        nhentai # ( ͡° ͜ʖ ͡°) 
	        peaclock tty-clock
	        pulsemixer #pulseaudioFull
	        unimatrix
            asciiquarium-transparent
            btop bottom
            pfetch #nitch
            pipes-rs
            pv
            speedtest-cli
            starfetch
        ;
    };
}
