# Don't do anything if not running interactively.
[[ $- != *i* ]] && return

export EDITOR=nvim
export DOTS_DIR=$HOME/dots
export NOTES_DIR=$HOME/notes
export PASSWORD_STORE_DIR=$HOME/ben/pass

# Notes
function note() {
  cd "$NOTES_DIR" && nvim "${1:-main.md}"
}

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
#HISTSIZE=10000
#SAVEHIST=10000
#HISTFILE=$ZDOTDIR/history
#HISTORY_IGNORE="(ls|ls *|cd|cd *|bat *|cat *|pwd|clear|history)"
unset HISTFILE # Disable history -> using atuin

# Keybinds
bindkey -v # vi mode
setopt extended_glob
setopt no_flowcontrol
bindkey -M viins '^[[H' beginning-of-line
bindkey -M viins '^[[F' end-of-line
bindkey -M viins '^[OH' beginning-of-line
bindkey -M viins '^[OF' end-of-line
bindkey -M vicmd '^[[H' beginning-of-line
bindkey -M vicmd '^[[F' end-of-line
bindkey -M vicmd '^[OH' beginning-of-line
bindkey -M vicmd '^[OF' end-of-line
# bindkey -M viins '^[[1~' beginning-of-line
# bindkey -M viins '^[[4~' end-of-line
# bindkey -M vicmd '^[[1~' beginning-of-line
# bindkey -M vicmd '^[[4~' end-of-line

# # Tab / Tab + Shift -> menu-complete / reverse-menu-complete
# bindkey -M vicmd '^[[Z' reverse-menu-complete
# bindkey -M viins '^[[Z' reverse-menu-complete

# Sources
source "$ZDOTDIR/.zsh_aliases"
source "$ZDOTDIR/.zsh_functions"

# Eval
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"

#starfetch
source "$DOTS_DIR/scripts/bash/check_repo.sh"
