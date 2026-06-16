# Don't do anything if not running interactively.
[[ $- != *i* ]] && return
export EDITOR=nvim
export NOTES=$HOME/notes
export PASSWORD_STORE_DIR=$HOME/sync/ben/pass

function note() {
  cd "$NOTES_DIR" && nvim "${1:-Main.md}"
}

# ALIASES
alias n='nvim'
alias m='ncmpcpp'
alias v='projectM-pulseaudio &>/dev/null & disown'

# NOTE: In case of FUNCNEST error, then do `unset yy` then `\yazi` or `command yazi`
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
alias yazi='yy'
alias l='yy'
alias lf='yy'

# Inactivity auto-command
if [[ -o interactive ]]; then
  TMOUT=180
  TRAPALRM() {
    case $((RANDOM % 3)) in
      0) unimatrix -s -n 94 2>/dev/null ;;
      1) pipes-rs ;;
      2) asciiquarium -t -s ;;
    esac
  }
fi

# Configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$ZDOTDIR/history
HISTORY_IGNORE="(ls|ls *|cd|cd *|bat *|cat *|pwd|clear|history)"

bindkey -v # vi mode
setopt extended_glob
setopt no_flowcontrol

# ───────────────────────── Keybinds ─────────────────────────
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

# Sources
source "$ZDOTDIR/.zsh_aliases"
source "$ZDOTDIR/.zsh_functions"
