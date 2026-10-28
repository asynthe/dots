_: {
  flake.modules.nixos.android =
    {
      pkgs,
      ...
    }:
    {
      #programs.nix-ld.enable = true;
      #programs.nix-ld.libraries = [ pkgs.libGL pkgs.glib ];

      #virtualisation.waydroid.enable = true;
      #services.gvfs.enable = true;
      sys.adminGroups = [
        "kvm"
        "adbusers"
      ];
      environment.systemPackages = with pkgs; [
        #androidsdk
        android-tools
        #android-studio
        #jmtpfs
        scrcpy
      ];
    };
}
