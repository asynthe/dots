_: {
  flake.modules.nixos.zram = _: {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };
  };
}
