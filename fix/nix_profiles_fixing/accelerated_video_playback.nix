{ config, pkgs, ... }: {

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    #extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
  };

}
