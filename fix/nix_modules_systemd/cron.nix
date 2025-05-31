{
  config,
  pkgs,
  ...
}: {
  # Cron is now deprecated, but you can still use it.
  # https://wiki.nixos.org/wiki/Cron

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/1 * * * *     asynthe     fd . '~/sync/system/wallpaper' -e jpg -e png | shuf -n 1 | tee >(xargs wal -i) >(xargs swww img -o eDP-1"
    ];
  };
}
