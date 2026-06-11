#! /usr/bin/env sh

if [ "$(uname -s)" != "Linux" ]; then
  echo "This script only supports Linux. Exiting."
  exit 1
fi

DOTS="$HOME/dots/config"
CFG="$HOME/.config"

make_link() {
  src="$1"
  tgt="$2"

  if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
    echo "ok     $tgt"
    return
  fi

  if [ -e "$tgt" ] || [ -L "$tgt" ]; then
    printf "exists %s — delete and replace with symlink? [y/N] " "$tgt"
    read -r answer
    case "$answer" in
      [yY]) rm -rf "$tgt" ;;
      *) echo "skipped $tgt"; return ;;
    esac
  fi

  mkdir -p "$(dirname "$tgt")"
  ln -sf "$src" "$tgt" && echo "linked $tgt"
}

for name in \
  bash cava direnv emacs ghostty \
  gtk-3.0 gtk-4.0 hypr jj mako \
  mpd mpv opencode qBittorrent sioyek \
  starship tmux waybar wezterm yazi \
  zathura zsh
do
  make_link "$DOTS/$name" "$CFG/$name"
done

# Cursor theme
make_link "$HOME/dots/other/icons/volantes" "$HOME/.local/share/icons/volantes"

# Zsh setup
printf "\nSet up zsh? (links .zshenv to point zsh to your dots config) [y/N] "
read -r answer
case "$answer" in
  [yY]) make_link "$DOTS/zsh/.zshenv" "$HOME/.zshenv" ;;
  *) echo "skipped zsh setup" ;;
esac

# Dark mode
printf "\nApply dark mode via dconf? [y/N] "
read -r answer
case "$answer" in
  [yY])
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
    echo "dark mode applied"
    ;;
  *) echo "skipped dark mode" ;;
esac

echo "\nDone."
