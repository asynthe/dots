{ pkgs, ... }: {
    home.packages = builtins.attrValues {
        inherit (pkgs)

            # Tools
            #linthesia # Synthesia replacement

            # Audio Tools
            #yabridge #yabridgectl
            #asunder # CD ripper and encoder
            #cadence # catia
            #patchance # JACK patchbay GUI
            #helvum # gtk patchbay for pipewire
            #easyeffects
            #qpwgraph
            #mp3gain

            # DAWs - Digital Audio Workstation
            #ardour
            bitwig-studio # paid
            mixxx # DJ mixer
            reaper
            renoise
            #zrythm

            # Other
            #fluidsynth
            #qsynth

            # Audio editors
            #ocenaudio #audacity

            # MP3
            #lame

            # Tag editors
            #easytag
            #tagger
            #puddletag
            #kid3

            # Tools
            #losslessaudiochecker # LAC
            #exactaudiocopy # EAC
            #friture # Real-time audio analyzer.

            # CD / DVD Tools
            #cdemu-client #cdemu-daemon
            #gcdemu
        ;
    };
}
