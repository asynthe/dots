{
    # Discord rich presence for mpd.
    services.mpd-discord-rpc = {
        enable = true;
        settings = {
            format = {
                details = "$title";
                state = "On $album by $artist";
                large_text = "$album";
                small_image = "";
            };
        };
    };
}
