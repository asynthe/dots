_: {
  flake.modules.nixos.cli = { pkgs, ... }: {
    # nix-direnv via /etc/direnv/direnvrc: cached `use flake` + GC roots.
    # The zsh hook stays in config/zsh/.zshrc, so don't add a second one.
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = false;
    };

    environment.systemPackages = with pkgs; [
      bat
      bc
      chafa
      exiftool
      eza
      fd
      ripgrep
      ffmpeg-full
      ffmpegthumbnailer
      file
      fzf
      skim
      ghostty.terminfo
      htop
      btop
      hyperfine
      imagemagickBig
      inxi
      jq
      killall
      libqalculate
      lsof
      mediainfo
      ncdu
      neomutt
      nh
      ntfs3g
      pciutils
      poppler-utils
      pv
      rsync
      smartmontools
      sox
      starship
      superfile
      tmux
      tmuxp
      tree
      unzip
      unar
      rar
      vim
      helix
      wget
      curl
      yazi
      lf
      yt-dlp
      zoxide

      cachix
      python3

      asciiquarium-transparent
      fastfetch
      pfetch-rs
      figlet
      lolcat
      pipes-rs
      starfetch
      tty-clock
      peaclock
      tenki
      clock-rs
      unimatrix
    ];
  };
}
