{ config, ... }: {

    mpdris2 = {
        enable = true;
        notifications = true;
        multimediaKeys = true;
        mpd = config.services.mpd.musicDirectory;
    };
}
