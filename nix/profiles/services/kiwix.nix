{ config, lib, pkgs, ... }:
with lib; with types;
let
    cfg = config.meta.services.kiwix;
in {
    # ───────────────────────── Options ─────────────────────────
    options.meta.services.kiwix.enable = mkEnableOption "Enable and set up Kiwix and other Android related tools.";

    #options.meta.services.kiwix.port = mkEnableOption "Enable and set up Kiwix and other Android related tools.";
    #options.meta.services.kiwix.library_path = mkEnableOption "Enable and set up Kiwix and other Android related tools.";

    # ───────────────────────── Configuration ─────────────────────────
    config = mkIf cfg.enable {

        environment.systemPackages = with pkgs; [
            kiwix
            kiwix-tools
        ];

        # TODO Add systemd service and systemd-timer to start daemon
        #kiwix-serve -p 3333 -l library.xml
        #kiwix-serve -p {cfg.port} -l {cfg.library_path)
        
        # TODO Add variable for library folder
        # TODO Add the script that recreates the library.xml
        # https://www.reddit.com/r/Kiwix/comments/t4ct7k/how_to_set_up_a_script_to_update_the_libraryxml/

        # #!/bin/bash
        # xml="/directory/for/library.xml"
        # library="/directory/for/kiwix/files.zim"
        #
        # log=($(find $library -name '*.zim' | sort))
        # if [ -f "$xml/library.log" ]; then
        #   IFS=$'\n' read -d '' -r -a oldlog < "$xml/library.log"
        # fi
        #
        # if [[ "${log[@]}" == "${oldlog[@]}" ]]; then
        #   echo No change
        # else
        #   echo Update library
        #   rm -f "$xml/library.log"
        #   rm -f "$xml/library_new.xml"
        #   for zim in "${log[@]}"; do
        #     echo $zim
        #     echo $zim >> "$xml/library.log"
        #     kiwix-manage "$xml/library_new.xml" add "$zim"
        #   done
        #   mv "$xml/library_new.xml" "$xml/library.xml"
        #   sudo systemctl restart kiwix
        # fi
    };
}
