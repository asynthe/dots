_: {
  flake.modules.nixos.soc-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      hping
      net-tools
      nmap
      tcpdump
      foremost
    ];
  };
}
