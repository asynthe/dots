# Don't do anything if not running interactively.
[[ $- != *i* ]] && return

# ───────────────────────── Environment Variables ─────────────────────────
# Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    # NixOS
    export NIXOS_XDG_OPEN_USE_PORTAL=1
    export NIXOS_OZONE_WL=1

    # User
    export NH_FLAKE=$HOME/dots # for `nh`
    export PASSWORD_STORE_DIR=$HOME/ben/pass/ben
    export WEZTERM_CONFIG_FILE=$HOME/.config/wezterm/.wezterm.lua
    #export GNUPGHOME=$HOME/ben/pass/gpg
    
    export ANKI_BASE=$HOME/disk/jp/anki
    export ANKI_WAYLAND=1

# macOS
elif [[ "$OSTYPE" == "darwin"* ]]; then

    # Brew stuff
    #source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
    #source /opt/homebrew/opt/chruby/share/chruby/auto.sh
    #chruby ruby-3.1.3

    # User
    export NH_FLAKE=$HOME/dots
    export PASSWORD_STORE_DIR=$HOME/ben/pass/ben

# Windows (WSL)
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then

    # User
    # ...
fi

# Variables
export EDITOR='nvim'
export BROWSER='librewolf'
export FILE='yazi'
export READER='sioyek'
export XDG_CURRENT_DESKTOP='Hyprland'

# Apps
export DIRENV_LOG_FORMAT=''
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export WAYFIRE_CONFIG_FILE=$HOME/.config/wayfire/wayfire.ini

# This is in my `.zshrc`
export BOOK_CURRENT=$HOME/disk/book/exam/security_plus/gibson_comptia_security_plus_get_certified.pdf
export BOOK_CURRENT_2=$HOME/disk/book/reading/learningviandvimeditors8e.pdf
export BOOK_FOLDER=$HOME/disk/book
export WALLPAPER_FOLDER=$HOME/dots/wallpaper
export WALLPAPER_VIDEO_FOLDER=$HOME/wallpaper/video
export WALLPAPER_VIDEO_PLAYLISTS=$HOME/wallpaper/video/playlists
export WALLPAPER_THUMBNAILS=$HOME/.cache/wallpaper_thumbnails

# PATH
export PATH="$HOME/dots/scripts/bash:$PATH"
export PATH="$HOME/dots/scripts/bash/hyprland:$PATH"
#export PATH="$HOME/dots/scripts/bash:$PATH"
#export PATH="$HOME/dots/scripts/bash/git:$PATH"
#export PATH="$HOME/.cargo/bin:$PATH"
#export PATH="$HOME/.local/bin:$PATH"
#export PATH="/usr/lib/ccache/bin:${PATH}"

# Check if variable exist, if not, then create the variable
if [ -d "$HOME/.bin" ] ;
  then PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ;
  then PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.emacs.d/bin" ] ;
  then PATH="$HOME/.emacs.d/bin:$PATH"
fi

if [ -d "$HOME/.config/emacs/bin/" ] ;
  then PATH="$HOME/.config/emacs/bin/:$PATH"
fi

if [ -d "$HOME/Applications" ] ;
  then PATH="$HOME/Applications:$PATH"
fi

if [ -d "/var/lib/flatpak/exports/bin/" ] ;
  then PATH="/var/lib/flatpak/exports/bin/:$PATH"
fi

if [ -z "$XDG_CONFIG_HOME" ] ; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z "$XDG_DATA_HOME" ] ; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z "$XDG_CACHE_HOME" ] ; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi

# ───────────────────────── Configuration ─────────────────────────
# Eval
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"

# Prompt
eval "$(starship init zsh)" # Starship - Prompt
#eval "$(starship init bash)" # if .bashrc
#PROMPT="> "
#RPROMPT="にゃ~"
#RPROMPT="]"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$ZDOTDIR/history
HISTORY_IGNORE="(ls|ls *|cd|cd *|bat *|cat *|pwd|clear|history)"

# Inactivity auto-command
if [[ -o interactive ]]; then # Only interactive. Don't run on scripts, SSH, or tmux
  TMOUT=180
  TRAPALRM() {
    case $((RANDOM % 3)) in
      0) unimatrix -s -n 94 2>/dev/null ;;
      1) pipes-rs ;;
      2) asciiquarium -t -s ;;
    esac
  }
fi

# ───────────────────────── Aliases ─────────────────────────
# Testing
alias jp='mpv --no-resume-playback https://iptv-org.github.io/iptv/countries/jp.m3u > /dev/null 2>&1 & disown'
#alias wtr='curl wttr.in/Perth'
#alias h='history | grep --color=auto'
#alias t='peaclock --config-dir ~/.config/peaclock'
#alias t='tty-clock -ScB'
#alias time='peaclock --config-dir ~/.config/peaclock'
#alias irc='tmux attach-session -t weechat'
#alias irc='weechat'

# Per Terminal
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    alias img='kitty +kitten icat'
elif [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    alias img='wezterm imgat'
fi

# Configurations
alias ghosttyconf='nvim $HOME/.config/ghostty/config'
alias hyprconf='nvim $HOME/.config/hypr/hyprland.conf'
alias mpvconf='nvim $HOME/.config/mpv/mpv.conf'
alias zshconf='nvim $HOME/.config/zsh/zshrc'
alias waybarconf='nvim $HOME/.config/waybar/config.jsonc'
alias wezconf='nvim $HOME/.config/wezterm/.wezterm.lua'

# Directories
alias ls='eza --icons --group-directories-first'
alias la='eza --icons -a --group-directories-first'
alias ll='eza --long --group-directories-first'
alias lla='eza --long -a --group-directories-first'
alias lg='eza --long --git --group-directories-first'

# Git
alias ga='git add -A'
alias gc='git commit -m "updating"'
alias gp='git push'

# Mistakes
alias apci='acpi'
alias sl='ls'
alias fuck='sudo !!'
alias dicker='docker'
alias dokcer='docker'
alias focker='docker'

# Main
alias ,='cd -'
alias ..='cd ..'
alias @='neomutt'
alias -g cat='bat'
alias -g info='mediainfo'
alias -g n='nvim'
alias -g nvv='sudo nvim'
alias -g pdf='zathura'
alias bt='bluetuith'
alias c='clear'
alias cls='clear' # Look ma i'm Powershell
alias cp='rsync -ah --info=progress2'
alias dsize='ncdu ${pwd}'
alias h='history | sk'
alias img='kitty +kitten icat' # Ghostty supports Kitty image protocol
alias m='ncmpcpp'
alias mime='xdg-mime query default'
alias nani='xdg-mime query filetype'
alias mimetype='xdg-mime query filetype'
alias py='python'
alias shell='which $SHELL'
alias v='alsamixer'
alias vv='pulsemixer'
alias w='watch -n 1'
alias yt-mp3='yt-dlp -f "ba" -x --audio-format mp3'
alias yt='yt-dlp -f "bv[ext=mp4]+ba[ext=m4a]" --merge-output-format mp4'
alias book='zathura $BOOK_CURRENT'
alias book_2='zathura $BOOK_CURRENT_2'
#alias book='fd . $BOOK_FOLDER --type f -e "pdf" -e "epub" | sk | xargs sioyek'
alias off='poweroff'
alias rm='rm -i'

# Grep
alias grep='grep -i --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Net
#alias scan='iwctl station wlan0 scan' # not using iwd now
alias wifi='sudo nmtui'
alias ifconfig='echo "ipconfig is deprecated, use ip instead."; false'
alias port='ss -naptu state listening'
alias ports='ss -tulanp'

# Other
alias doc='libreoffice'
alias docx='libreoffice'
alias excel='libreoffice'
alias word='libreoffice'
alias ani-on='hyprctl keyword animations:enabled 1'
alias ani-off='hyprctl keyword animations:enabled 0'
#alias ani-off='hyprgame'

# Fun
alias kernel-soul-8hz='aplay /dev/random'
alias kernel-soul-pa='pacat /dev/urandom'
alias kernel-soul='aplay -c 2 -f S16_LE -r 44100 /dev/random'
alias rickroll='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# Wallpaper
alias wall='fd . $WALLPAPER_FOLDER -e jpg -e png | sk | xargs swww img'
alias video='fd . $WALLPAPER_VIDEO_FOLDER -e mp4 | sk | xargs mpvpaper -vp -o "loop-file=inf --hwdec=nvdec --panscan=1 --no-resume-playback" "*"'
alias playlist='fd . $WALLPAPER_VIDEO_PLAYLISTS -e m3u | sk | xargs mpvpaper -vp -o "loop-playlist=inf --hwdec=nvdec --panscan=1 --shuffle --no-resume-playback" "*"'

# Flatpak
flatpak_check() {
  if ! command -v flatpak &>/dev/null; then
    echo "[!] Flatpak is not installed on this system. Please install it first." >&2
    return 1
  fi
}

fightcade() {
  flatpak_check || return
  flatpak run com.fightcade.Fightcade
}

pinball() {
  flatpak_check || return
  flatpak run com.github.k4zmu2a.spacecadetpinball
}

upscayl() {
  flatpak_check || return
  flatpak run org.upscayl.Upscayl
}

# ───────────────────────── Keybinds ─────────────────────────
# Configuration
bindkey -v # vi mode
setopt extended_glob
setopt no_flowcontrol

# Home / End
bindkey -M viins '^[OH' beginning-of-line
bindkey -M viins '^[OF' end-of-line
bindkey -M viins '^[[H' beginning-of-line
bindkey -M viins '^[[F' end-of-line
bindkey -M viins '^[[1~' beginning-of-line
bindkey -M viins '^[[4~' end-of-line
bindkey -M vicmd '^[OH' beginning-of-line
bindkey -M vicmd '^[OF' end-of-line
bindkey -M vicmd '^[[H' beginning-of-line
bindkey -M vicmd '^[[F' end-of-line
bindkey -M vicmd '^[[1~' beginning-of-line
bindkey -M vicmd '^[[4~' end-of-line

# Tab / Tab + Shift -> menu-complete / reverse-menu-complete
bindkey -M vicmd '^[[Z' reverse-menu-complete
bindkey -M viins '^[[Z' reverse-menu-complete

# Keybinds
#bindkey -s '^I' 'pactl set-sink-volume 0 -5%; clear^M'
#bindkey -s '^O' 'pactl set-sink-volume 0 +5%; clear^M'
bindkey -s '^Q' 'qalc^M'
bindkey -s '^E' 'srczsh; clear^M'
bindkey -s '^T' 'tmux^M'
bindkey -r '^F'
bindkey -s '^F' 'lf^M'
bindkey -r '^V'
bindkey -s '^V' 'cava^M'
bindkey -s '^B' 'bluetuith^M'
bindkey -s '^N' 'ncmpcpp^M'
bindkey -s '^X' 'nvim^M'
bindkey -r '^Z' # Unbinded for tmux zoom pane instead of send into bg.

# ───────────────────────── Other ─────────────────────────
# Yazi + cd
# NOTE: In case of FUNCNEST error, then do `unset yy` then `\yazi` or `command yazi`
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias yazi='yy'
alias l='yy'
alias lf='yy'

# ───────────────────────── Plugins ─────────────────────────
source $ZDOTDIR/plugin/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $ZDOTDIR/plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

function zvm_config() {
  ZVM_CURSOR_STYLE_ENABLED=true
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
}

# Suppress zsh-vi-mode errors
functions[zvm_bindkey]='
  () {
    [[ -z "$1" ]] && return 0
    builtin bindkey "$@" 2>/dev/null || return 0
  }
'
