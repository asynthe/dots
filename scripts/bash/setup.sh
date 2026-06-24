#! /usr/bin/env bash

# TODO, Get zsh submodules (plugins)

# ASCII
# TODO Use this cat on LUKS unlock

# TODO Zsh setup
# symlink to .zshenv in dots/config/zsh?
# TODO 

# TODO Can I run the flake from inside a Windows folder?
# TODO If WSL is detected, then add a symlink to `/mnt/c/Users/ben/Desktop` to `$HOME`.
# -> Ask what the Windows username is?

# TODO Firefox symlink of user overrides, just copying command i ran
# ln -sf ~/dots/config/firefox/user-overrides.js ~/.config/mozilla/firefox/q5a5uclv.default/

display_ascii_art() {
    cat << "EOF" | pv -qL 470
  ⣴⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣼⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣼⣿⣿⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣤⣶⣶⣿⣿⡗
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟ 
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀
⣿⣿⡇⠜⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ⠀  
⣿⣿⣿⣶⣿⣿⣿⣿⣿⠋⡹⠙⣿⣿⣿⡇⠀⠀  
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣿⣿⠛⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠁⠀⠀⠀⠀⠀⠀
⣿⣿⡿⠻⠿⠿⠿⠿⠛⠹⠑⠀⠀       
⠟                   
EOF
}

echo "--------------- Symlink script for dotfiles ---------------"
display_ascii_art
sleep 1

# Set variables based on OS
# $OSTYPE -> Given by the system or `uname`.

# Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source_base="$HOME/dots/config"
  dest_path="$HOME/.config"

# macOS
elif [[ "$OSTYPE" == "darwin"* ]]; then
  source_base="$HOME/ben/dots/config"
  dest_path="$HOME/.config"
else
  echo "[X] Unsupported OS: $OSTYPE"
  exit 1
fi

sleep 0.5
echo "[!] Detected OS: $OSTYPE"
sleep 0.5
echo "[!] Dotfiles will be symlinked to: $dest_path"
sleep 1

# Ensure .config directory exists
mkdir -p "$dest_path"

# Confirmation Prompt
read -rp "[?] Do you want to continue? (y/n) " confirm
if [[ "$confirm" != [Yy] ]]; then
  echo "[-] Operation cancelled."
  exit 0
fi

#configs=(
#  "alacritty"
#  "bash" # TODO Haven't got a config yet, but this can do.
#  "cava"
#  "direnv"
#  "emacs"
#  "ghostty"
#  "hypr"
#  "kitty"
#  "mako"
#  "mpd"
#  "mpv"
#  "ncmpcpp"
#  "nushell"
#  "nvim"
#  "rofi"
#  "sioyek"
#  "starship"
#  "tmux"
#  "vis"
#  "waybar"
#  "wayfire"
#  "wezterm"
#  "wofi"
#  "xmobar"
#  "xmonad"
#  "yazi"
#  "zathura"
#  "zsh"
#)

# Create directories and symlink files
# TODO librewolf symlink ../config/librewolf/librewolf.overrides.cfg -> ~/.librewolf/librewolf.overrides.cfg
for config in "${configs[@]}"; do
  src="$source_base/$config"
  target="$dest_path/$config"

  echo "[+] Symlinking $config..."
  sleep 0.2

  if [[ -e "$src" ]]; then
    mkdir -p "$(dirname "$target")"
    ln -sfn "$src" "$target"
  else
    echo "[!] Warning: Source $src does not exist. Skipping..."
  fi
done

sleep 1
echo "--------------- Finished! ---------------"

# zsh
#ln -sf $HOME/.config/zsh/.zshenv $HOME/.zshenv

# mpd
#touch $HOME/.config/mpd/playlists
#ln -sf $HOME/.config/zsh/.zshenv $HOME/.zshenv
#ln -sf $XDG_DATA_HOME/Trash $HOME/trash
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
# TODO ...
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

# TODO Add
# ln -sf $HOME/dots/config/VSCodium/User/settings.json $HOME/.config/VSCodium/User/settings.json
# ln -sf $HOME/dots/config/VSCodium/User/keybindings.json $HOME/.config/VSCodium/User/keybindings.json
