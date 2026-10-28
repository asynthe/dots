_: {
  flake.modules.nixos.android =
    {
      pkgs,
      ...
    }:
    {

      sys.adminGroups = [
        "kvm"
        "adbusers"
      ];
      environment.systemPackages = with pkgs; [
        android-tools
        scrcpy
      ];
    };
}
