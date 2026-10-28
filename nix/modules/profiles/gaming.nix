{ config, ... }:
{
  # Steam, Wine and native games.
  flake.modules.nixos.profile-gaming = {
    imports = with config.flake.modules.nixos; [
      steam
      wine
      lutris
      osu-lazer
      stepmania
      star-citizen
      star-citizen-cache
      uzdoom
    ];
  };
}
