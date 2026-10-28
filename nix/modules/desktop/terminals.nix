_: {
  flake.modules.nixos.terminals = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      alacritty
      ghostty
      kitty
      warp-terminal
      wezterm
    ];
  };
}
