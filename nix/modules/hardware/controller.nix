_: {
  flake.modules.nixos.controller =
    {
      pkgs,
      ...
    }:
    {
      hardware.xpadneo.enable = true;
      sys.adminGroups = [ "input" ];
      environment.systemPackages = with pkgs; [
        dualsensectl
      ];
    };
}
