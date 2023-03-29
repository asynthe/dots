#welcome message
#$HOME/sync/sys/scripts/random-quote.sh
#pfetch

# PROMPT
# starship
eval "$(starship init zsh)"
#PROMPT="> "
#RPROMPT="にゃ~"
#RPROMPT="]"

# PATH
# export PATH=$PATH:...
export PATH="/home/asynthe/.cargo/bin:$PATH"
export PATH="/home/asynthe/.local/bin:$PATH"
export PATH="/home/asynthe/.emacs.d/bin:$PATH"
export PATH="/usr/lib/ccache/bin:${PATH}"
export CHROME_PATH=/usr/bin/brave-bin
export PASSWORD_STORE_DIR=~/main/ベンハミン/pass
export STARSHIP_CONFIG=~/.config/starship/starship.toml

export RUSTC_WRAPPER=/usr/bin/sccache
export SCCACHE_DIR=/var/cache/sccache
export SCCACHE_MAX_FRAME_LENGTH=104857600

# sources
source $ZDOTDIR/aliases
source $ZDOTDIR/files/lfcd
source $ZDOTDIR/files/cdls

# bindings
setopt extended_glob
setopt no_flowcontrol
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
## sound volume
bindkey -s '^O' 'pactl set-sink-volume 0 -5% && clear^M'
bindkey -s '^P' 'pactl set-sink-volume 0 +5% && clear^M'
## keyboard binds
bindkey -s '^Q' 'qalc && clear^M'
bindkey -s '^W' 'telnet mapscii.me^M'
#bindkey -s '^R' 'record^M' (ffmpeg alias)
bindkey -s '^A' 'ncmpcpp^M'
bindkey -s '^S' 'vis^M'
bindkey -s '^F' 'open_with_fzf^M'
bindkey -s '^J' 'journal^M'
bindkey -s '^Z' 'lfcd^M'
bindkey -s '^X' 'cd_with_fzf^M'
bindkey -s '^V' 'alsamixer^M'
bindkey -s '^B' 'blueman-manager^M'
bindkey -s '^N' 'notes^M'

# EXPORTS
export EDITOR='nvim'
export TERMINAL="alacritty"
export BROWSER='librewolf'
export READER='zathura'
export FILE='lf'
export QT_STYLE_OVERRIDE=adwaita-dark

# history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# TIMEOUT PIPES.SH
#TMOUT=30
#TRAPALRM() { /usr/local/bin/pipes.sh }

# plugins
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#source $ZDOTDIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
