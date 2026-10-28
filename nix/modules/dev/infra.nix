_: {
  flake.modules.nixos.infra = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      opentofu
      ansible
      ansible-lint
    ];
  };
}
