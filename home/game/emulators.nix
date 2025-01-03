{ pkgs, ... }: {

    home.packages = builtins.attrValues {
        inherit (pkgs)

            # Sony
            #ppsspp #ppsspp-qt # PSP
            #ppsspp-sdl-wayland # PSP on wayland
            #pcsx2 # PS2
            #rpcs3 # PS3

            # Sega
            # Genesis / Mega Drive
            # Sega Saturn
            #flycast # Dreamcast / Naomi / Atomiswave
            #redream # Dreamcast (not yet implemented)

            # Microsoft
            #xemu # Xbox

            # Nintendo
            #mgba #vbam Game Boy Advanced
            #bsdnes-hd #snes9x #zsnes # Super Nintendo
            #mupen64plus # Nintendo 64
            #dolphin-emu # Gamecube / Wii
            #desmume # DS
            #citra-nightly #citra-canary # 3DS
            #cemu # Wii U
            #yuzu-mainline #ryujinx # Switch

            # Various
            #mame #mame-tools
            #dosbox #dosbox-staging # DOS
            #mednafen # Play Station, NEC PC Engine, PC-FX, Sega Saturn, Nintendo Virtual Boy.
            #mednaffe # Frontend for Mednafen.

            # RetroArch
            # (moving to Steam's RetroArch)
            #retroarchFull
            #retroarch-assets

            #(retroarch.override { # Retroarch with specific libraries
              #cores = with libretro; [
                #genesis-plus-gx
                #beetle-psx
                #beetle-psx-hw
                #dolphin
                #flycast
                #snes9x
                #mupen64plus
                #parallel-n64
                #pcsx2
                #ppsspp
                #vba-next
              #];
            #})
        ;
    };
}
