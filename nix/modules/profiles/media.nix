{ config, ... }:
{
  # Everyday apps: music, documents, torrents.
  flake.modules.nixos.profile-media = {
    imports = with config.flake.modules.nixos; [
      flatpak
      gimp
      kiwix
      monero
      qbittorrent
      irc
      music
      tectonic
      typst
    ];
  };
}
