# macOS stuff
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.3

# -------------- Environment Variables --------------
export EDITOR='nvim'
export BROWSER='librewolf'
export FILE='yazi'
export FLAKE='/home/meow/sync/flake'
export READER='zathura'
#export TERM='xterm-256color'
#export QT_STYLE_OVERRIDE=adwaita-dark

export GNUPGHOME=$HOME/sync/pass/gpg # default `$HOME/.gnupg`
export PASSWORD_STORE_DIR=$HOME/sync/pass/pass # default `$HOME/.password-store`
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml # default `$HOME/.config/starship.toml`, also $ZDOTDIR/starship/starship.toml to have inside zsh folder.
export WAYFIRE_CONFIG_FILE=$HOME/.config/wayfire/wayfire.ini # Instead of $HOME/.config/wayfire.ini

# NixOS and Hyprland specific
NIXOS_XDG_OPEN_USE_PORTAL=1
NIXOS_OZONE_WL=1
XDG_CURRENT_DESKTOP='Hyprland'

# -------------- Aliases --------------
# Directories
alias ls='eza --icons --group-directories-first'
alias la='eza --icons -a --group-directories-first'
alias ll='eza --long --group-directories-first'
alias lla='eza --long -a --group-directories-first'
alias lg='eza --long --git --group-directories-first'

# Mistakes
alias sl='ls'
alias fuck='sudo !!'
alias dicker='docker'
alias dokcer='docker'
alias focker='docker'

# Dev
alias py='python'

# Main
alias ,='cd -'
alias -g c='bat' # cat -> bat
alias ..='cd ..'
alias @='neomutt'
alias cp='rsync -ah --info=progress2'
alias dsize='ncdu ${pwd}'
alias h='history | sk'
alias ifconfig='echo "ipconfig is deprecated, use ip instead."; false'
alias m='ncmpcpp'
alias n='nvim'
alias nm='doas nmtui'
alias port='ss -naptu state listening'
alias ports='ss -tulanp'
alias v='pulsemixer'
alias vv='alsamixer'
alias w='watch'
alias wapp='xdg-mime query default'
alias wshell='which $SHELL'
alias wtype='xdg-mime query filetype'
#alias scan='iwctl station wlan0 scan' # not using iwd now
#alias -g cat='bat' # Problems with pywal

# Grep
alias grep='grep -i --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Apps
alias bt='bluetuith'
alias doc='libreoffice'
alias docx='libreoffice'
alias excel='libreoffice'
alias word='libreoffice'
alias yt-mp3='yt-dlp -f "ba" -x --audio-format mp3'
alias yt='yt-dlp -f "bv[ext=mp4]+ba[ext=m4a]" --merge-output-format mp4'
alias -g info='mediainfo'
alias -g nv='nvim' 
alias -g nvv='doas nvim'
alias -g pdf='zathura'
alias ani-on='hyprctl keyword animations:enabled 1'
alias ani-off='hyprctl keyword animations:enabled 0'
#alias ani-off='hyprgame'

# Books
alias book='fd . ~/sync/study/book --type f -e "pdf" -e "epub" | sk | xargs zathura'
alias books='fd . ~/sync/archive/book --type f -e "pdf" -e "epub" | sk | xargs zathura'
alias bookjp='fd . ~/sync/archive/jp/book -e "pdf" -e "epub" | sk | xargs zathura'

# TV


# Fun
alias kernel-soul-8hz='aplay /dev/random'
alias kernel-soul-pa='pacat /dev/urandom'
alias kernel-soul='aplay -c 2 -f S16_LE -r 44100 /dev/random'
alias fightcade='flatpak run com.fightcade.Fightcade'
alias pinball='flatpak run com.github.k4zmu2a.spacecadetpinball'
alias rickroll='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
alias upscayl='flatpak run org.upscayl.Upscayl'

# Wallpaper
alias swww-random='~/sync/archive/script/bash/swww/randomize.sh /home/asynthe/sync/system/wallpaper/favourite'
alias wall='fd . ~/sync/archive/wallpaper/img -e jpg -e png | sk | xargs swww img'
alias wallp='fd . ~/sync/archive/wallpaper/img -e jpg -e png | sk | tee >(xargs wal -i) >(xargs swww img)'
alias wallpy='fd . ~/sync/archive/wallpaper -e jpg -e png | ~/script/bash/fzf_preview | tee >(xargs wal -i) >(xargs swww img)'
alias video='fd . ~/sync/archive/wallpaper/video -e mp4 | sk | xargs mpvpaper -v -p -o "loop-file=inf" "*"'
alias loop='fd . ~/sync/system/wallpaper/loop -e mp4 | sk | xargs mpvpaper -v -s -o "loop-file=inf" eDP-1'

# TESTING #
alias pl='mpvpaper -v -s -o "shuffle loop-playlist=inf" "*" ~/sync/system/wallpaper/video/anime_playlist.m3u'
alias pl-na='mpvpaper -v -s -o "no-audio shuffle loop-playlist=" "*" ~/sync/system/wallpaper/video/anime_playlist.m3u'
alias tv-jp='mpvpaper -v -s "*" https://iptv-org.github.io/iptv/countries/jp.m3u'
alias tv-cl='mpvpaper -v -s "*" https://iptv-org.github.io/iptv/countries/cl.m3u'
alias tv-au='mpvpaper -v -s "*" https://i.mjh.nz/au/Perth/raw-tv.m3u8'

# Other
#alias wtr='curl wttr.in/Perth'
#alias h='history | grep --color=auto'
#alias t='peaclock --config-dir ~/.config/peaclock'
#alias time='peaclock --config-dir ~/.config/peaclock'
#alias irc='tmux attach-session -t weechat'

# -------------- Keybinds --------------
setopt extended_glob
setopt no_flowcontrol
# shopt autocd for bashrc # cd with ..

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
#bindkey -s '^I' 'pactl set-sink-volume 0 -5%; clear^M'
#bindkey -s '^O' 'pactl set-sink-volume 0 +5%; clear^M'
bindkey -s '^Q' 'qalc^M'
bindkey -s '^E' 'srczsh; clear^M'
bindkey -s '^T' 'tmux^M'
bindkey -r '^F' # Remove
bindkey -s '^F' 'lf^M' # Add
bindkey -r '^V'
bindkey -s '^V' 'cava^M'
bindkey -s '^B' 'bluetuith^M'
bindkey -s '^N' 'ncmpcpp^M'
bindkey -s '^X' 'nvim^M'
bindkey -r '^Z' # Unbinded for tmux zoom pane instead of send into bg.

# -------------- Configuration --------------
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
#eval "$(starship init bash)" # if .bashrc

#PROMPT="> "
#RPROMPT="にゃ~"
#RPROMPT="]"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
HISTORY_IGNORE="(ls|ls *|cd|cd *|bat *|cat *|pwd|clear|history)"
TMOUT=420
TRAPALRM() { unimatrix -s 93 }
#TRAPALRM() { pipes-rs }

[[ $- != *i* ]] && return # Don't do anything if not running interactively.

export PATH="$HOME/sync/dots/script/bin:$PATH"
export PATH="$HOME/sync/dots/script/bash/git:$PATH"
#export PATH="$HOME/.cargo/bin:$PATH"
#export PATH="$HOME/.local/bin:$PATH"
#export PATH="/usr/lib/ccache/bin:${PATH}"

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

# -------------- Plugins --------------
function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

  ZVM_CURSOR_STYLE_ENABLED=true
  
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
}

source $ZDOTDIR/plugin/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $ZDOTDIR/plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------- Other --------------
lfcd () {
    # `command` is needed in case `lfcd` is aliased to `lf`
    cd "$(command lf -print-last-dir "$@")"
}

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias yazi='yy'
alias lf='lfcd'
