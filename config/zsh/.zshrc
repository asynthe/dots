# Don't do anything if not running interactively.
[[ $- != *i* ]] && return

export DOTS_DIR=$HOME/git/dots
export EDITOR=nvim
export GNUPGHOME=$HOME/.local/share/gnupg
export GPG_TTY=$(tty)
export NOTES_DIR=$HOME/git/notes
export PASSWORD_STORE_DIR=$HOME/git/auth/pass
export SOPS_AGE_KEY_FILE=$HOME/git/auth/age/keys.txt

if [[ -o interactive ]]; then
  TMOUT=180
  TRAPALRM() {
    local -a s
    (( $+commands[unimatrix] )) && s+=('unimatrix -s -n 94 2>/dev/null')
    (( $+commands[pipes-rs] )) && s+=('pipes-rs')
    (( $+commands[asciiquarium] )) && perl -MTerm::Animation -e1 2>/dev/null && s+=('asciiquarium -t -s')
    (( $#s )) && eval "${s[RANDOM % $#s + 1]}"
  }
fi

unset HISTFILE # Disable history -> using atuin

bindkey -v
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

# Prompt: user@host path $ (# as root), terminal's default colour
PROMPT='%n@%m %~ %(!.#.$) '

source "$ZDOTDIR/.zsh_aliases"
source "$ZDOTDIR/.zsh_functions"

eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"

check_repo

# pnpm
export PNPM_HOME='/home/meow/.local/share/pnpm'
case ":$PATH:" in
  ":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
