{ ... }:
{
    flake.modules.nixos.music = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            cava
            cliamp
            cmus
            mixxx
            mpd ncmpcpp rmpc
            spek
            #projectm_3 # Milkdrop 3
        ];
    };
}
