{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        mpd ncmpcpp
        mixxx
        spek
        projectm_3 # Milkdrop 3

        # Audio vis and others
        alsa-utils pulsemixer
        cava
        cmus
    ];
}
