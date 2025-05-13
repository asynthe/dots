# TODO ASCII Art Here

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
    #export GNUPGHOME=$HOME/ben/pass/gpg

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
#export TERM='xterm-256color' # TODO Testing
#export QT_STYLE_OVERRIDE='adwaita-dark' # TODO Testing
export XDG_CURRENT_DESKTOP='Hyprland'

# Apps
export DIRENV_LOG_FORMAT=''
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export WAYFIRE_CONFIG_FILE=$HOME/.config/wayfire/wayfire.ini

# This is in my `.zshrc`
# User
#export BOOK_PATH=$HOME/study/book/cybersecurity_ops_with_bash/cybersecurityopswithbash.pdf
export BOOK_FOLDER=$HOME/study/archive_book
export WALLPAPER_FOLDER=$HOME/dots/wallpaper
export WALLPAPER_VIDEO_FOLDER=$HOME/wallpaper/video
export WALLPAPER_THUMBNAILS=$HOME/.cache/wallpaper_thumbnails

# Add to PATH
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
      0) unimatrix -s 93 2>/dev/null ;;
      1) pipes-rs ;;
      2) asciiquarium -t -s ;;
    esac
  }
fi

# ───────────────────────── Aliases ─────────────────────────
# Directories
alias ls='eza --icons --group-directories-first'
alias la='eza --icons -a --group-directories-first'
alias ll='eza --long --group-directories-first'
alias lla='eza --long -a --group-directories-first'
alias lg='eza --long --git --group-directories-first'

# Mistakes
alias H='Hyprland'
alias sl='ls'
alias fuck='sudo !!'
alias dicker='docker'
alias dokcer='docker'
alias focker='docker'

# Testing
alias jp='mpv --no-resume-playback https://iptv-org.github.io/iptv/countries/jp.m3u > /dev/null 2>&1 & disown'

# Main
# NOTE Wezterm uses 'wezterm imgcat' so see if it's possible to configure
alias ,='cd -'
alias ..='cd ..'
alias @='neomutt'
alias -g c='bat' # cat -> bat
alias -g cat='bat'
alias -g info='mediainfo'
alias -g n='nvim'
alias -g nv='nvim' 
alias -g nt='nvim +Neorg\ index'
alias -g note='nvim +Neorg\ index'
alias -g nvv='sudo nvim'
alias -g pdf='sioyek'
alias bt='bluetuith'
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
alias v='pulsemixer'
alias vv='alsamixer'
alias w='watch -n 1'
alias yt-mp3='yt-dlp -f "ba" -x --audio-format mp3'
alias yt='yt-dlp -f "bv[ext=mp4]+ba[ext=m4a]" --merge-output-format mp4'
alias book='fd . $BOOK_FOLDER --type f -e "pdf" -e "epub" | sk | xargs sioyek' # TODO Less verbose

# Other
#alias wtr='curl wttr.in/Perth'
#alias h='history | grep --color=auto'
#alias t='peaclock --config-dir ~/.config/peaclock'
#alias time='peaclock --config-dir ~/.config/peaclock'
#alias irc='tmux attach-session -t weechat'
#alias irc='weechat'

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
setopt extended_glob
setopt no_flowcontrol
# shopt autocd for bashrc # cd with ..

# Keybinds
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
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

# ───────────────────────── Plugins ─────────────────────────
source $ZDOTDIR/plugin/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $ZDOTDIR/plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_CURSOR_STYLE_ENABLED=true
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
}

# ───────────────────────── Other ─────────────────────────
# Yazi + cd
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
