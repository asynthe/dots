{ config, pkgs, ... }:

let
    cleaner = pkgs.writeShellApplication {
        name = "cleaner.sh";
	#runtimeInputs = [ ];
	text = ''
            #!/bin/sh
            ${pkgs.ueberzugpp}/bin/ueberzugpp cmd -s SUB_SOCKET -a remove -i PREVIEW 
        '';
    };

    preview = pkgs.writeShellApplication {
        name = "previewer.sh";
	#runtimeInputs = [ ];
	text = ''
            #!/bin/sh

            image() {
              FILE_PATH="$1"
              X=$4
              Y=$5
              MW=$(($2 - 1))
              MH=$3
              ${pkgs.ueberzugpp}/bin/ueberzugpp cmd -s "$UB_SOCKET" -a add -i PREVIEW -x "$X" -y "$Y" --max-width "$MW" --max-height "$MH" -f "$FILE_PATH"
              exit 1
            }

            batorcat() {
              file="$1"
              shift
              if command -v ${pkgs.bat}/bin/bat >/dev/null 2>&1; then
                ${pkgs.bat}/bin/bat --color=always --style=plain --pager=never "$file" "$@"
              else
                cat "$file"
              fi
            }

            CACHE="${config.home.homeDirectory}/.cache/lf/thumbnail.$(${pkgs.coreutils}/bin/stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(${pkgs.coreutils}/bin/readlink -f "$1")" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.gawk}/bin/awk '{print $1}'))"

            case "$(printf "%s\n" "$(readlink -f "$1")" | ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')" in
              *.tgz | *.tar.gz) ${pkgs.gnutar}/bin/tar tzf "$1" ;;
              *.tar.bz2 | *.tbz2) ${pkgs.gnutar}/bin/tar tjf "$1" ;;
              *.tar.txz | *.txz) ${pkgs.xz}/bin/xz --list "$1" ;;
              *.tar) ${pkgs.gnutar}/bin/tar tf "$1" ;;
              *.zip | *.jar | *.war | *.ear | *.oxt) ${pkgs.unzip}/bin/unzip -l "$1" ;;
              *.rar) ${pkgs.unrar}/bin/unrar l "$1" ;;
              *.7z) ${pkgs.p7zip}/bin/7z l "$1" ;;
              *.[1-8]) ${pkgs.man}/bin/man "$1" | ${pkgs.util-linux}/bin/col -b ;;
              *.o) nm "$1" ;;
              # *.torrent) transmission-show "$1" ;;
              *.iso) ${pkgs.libcdio}/bin/iso-info --no-header -l "$1" ;;
              *.odt | *.ods | *.odp | *.sxw) ${pkgs.odt2txt}/bin/odt2txt "$1" ;;
              *.doc) ${pkgs.catdoc}/bin/catdoc "$1" ;;
              # *.docx) docx2txt "$1" - ;;
              *.xls | *.xlsx)
                ${pkgs.gnumeric}/bin/ssconvert --export-type=Gnumeric_stf:stf_csv "$1" "fd://1" | batorcat --language=csv
                ;;
              *.wav | *.mp3 | *.flac | *.m4a | *.wma | *.ape | *.ac3 | *.og[agx] | *.spx | *.opus | *.as[fx] | *.mka)
                ${pkgs.exiftool}/bin/exiftool "$1"
                ;;
              *.pdf)
                [ ! -f "''${CACHE}.jpg" ] && ${pkgs.poppler_utils}/bin/pdftoppm -jpeg -f 1 -singlefile "$1" "$CACHE"
                image "''${CACHE}.jpg" "$2" "$3" "$4" "$5"
                ;;
              *.avi | *.mp4 | *.wmv | *.dat | *.3gp | *.ogv | *.mkv | *.mpg | *.mpeg | *.vob | *.fl[icv] | *.m2v | *.mov | *.webm | *.ts | *.mts | *.m4v | *.r[am] | *.qt | *.divx)
                [ ! -f "''${CACHE}.jpg" ] && ${pkgs.ffmpegthumbnailer}/bin/ffmpegthumbnailer -i "$1" -o "''${CACHE}.jpg" -s 0 -q 5
                image "''${CACHE}.jpg" "$2" "$3" "$4" "$5"
                ;;
              *.bmp | *.jpg | *.jpeg | *.png | *.xpm | *.webp | *.gif | *.jfif)
                image "$1" "$2" "$3" "$4" "$5"
                ;;
              *.svg)
                [ ! -f "''${CACHE}.jpg" ] && ${pkgs.imagemagick}/bin/convert "$1" "''${CACHE}.jpg"
                image "''${CACHE}.jpg" "$2" "$3" "$4" "$5"
                ;;
              *)
                batorcat "$1"
                ;;
            esac
            exit 0 
        '';
    };

    lfub = pkgs.writeShellApplication {
        name = "lfub";
	#runtimeInputs = [ ];
	text = ''
            #!/bin/sh

            # This is a wrapper script for lf that allows it to create image previews with
            # ueberzug. This works in concert with the lf configuration file and the
            # lf-cleaner script.

            set -e

            UB_PID=0
            UB_SOCKET=""

            case "$(uname -a)" in
              *Darwin*) UEBERZUG_TMP_DIR="$TMPDIR" ;;
              *) UEBERZUG_TMP_DIR="/tmp" ;;
            esac

            cleanup() {
              exec 3>&-
              ueberzugpp cmd -s "$UB_SOCKET" -a exit
            }

            if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
              lf "$@"
            else

              [ ! -d "${config.home.homeDirectory}/.cache/lf" ] && mkdir -p "${config.home.homeDirectory}/.cache/lf"
              UB_PID_FILE="$UEBERZUG_TMP_DIR/.$(uuidgen)"
              ${pkgs.ueberzugpp}/bin/ueberzugpp layer --silent --no-stdin --use-escape-codes --pid-file "$UB_PID_FILE"
              UB_PID=$(cat "$UB_PID_FILE")
              rm "$UB_PID_FILE"
              UB_SOCKET="$UEBERZUG_TMP_DIR/ueberzugpp-''${UB_PID}.socket"
              export UB_PID UB_SOCKET
              trap cleanup HUP INT QUIT TERM EXIT
              lf "$@" 3>&-
            fi 
        '';
    };

in {

    programs.lf.extraConfig = ''
      #set previewer = ${preview}
      #set cleaner = ${cleaner}

      # For testing
      # ${lfub} 
    '';

    # IN PROGRESS
    # Add the next function to zsh / bash
    #zsh.extraConfig = ''
      #lfcd () {
          # `command` is needed in case `lfcd` is aliased to `lf`
          #cd "$(command lf -print-last-dir "$@")"
      #} '';
}
