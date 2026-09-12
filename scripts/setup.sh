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
# ln -sf ~/git/dots/config/firefox/user-overrides.js ~/.config/mozilla/firefox/q5a5uclv.default/

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
  source_base="$HOME/git/dots/config"
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

DOTS="$HOME/git/dots/config"
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
  alacritty bash cava direnv emacs \
  fuzzel ghostty gtk-3.0 gtk-4.0 hypr \
  jj kitty mako mpd mpv \
  opencode qBittorrent quickshell sioyek starship \
  tmux waybar wezterm yazi zathura \
  zsh
do
  make_link "$DOTS/$name" "$CFG/$name"
done

# Cursor theme
make_link "$HOME/git/dots/other/icons/volantes" "$HOME/.local/share/icons/volantes"

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

# Fonts
# GTK reads dconf *before* gtk-3.0/settings.ini, so these keys silently win over
# the repo's gtk-font-name. They shipped as 'Segoe UI 9' / 'Hack 10' -- neither
# font installed -- which is why Firefox's chrome ignored the dotfiles entirely.
# Keep these in step with config/gtk-{3,4}.0/settings.ini.
printf "\nApply font settings via dconf? [y/N] "
read -r answer
case "$answer" in
  [yY])
    dconf write /org/gnome/desktop/interface/font-name "'JetBrainsMono Nerd Font 10'"
    dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 14'"
    dconf write /org/gnome/desktop/interface/document-font-name "'Noto Sans 14'"
    echo "fonts applied"
    ;;
  *) echo "skipped font setup" ;;
esac

echo "\nDone."

# TODO Add
# ln -sf $HOME/git/dots/config/VSCodium/User/settings.json $HOME/.config/VSCodium/User/settings.json
# ln -sf $HOME/git/dots/config/VSCodium/User/keybindings.json $HOME/.config/VSCodium/User/keybindings.json

# TODO What logic should we use (?)
# -> Symlinking folders and gitignoring extra files that may be created by apps
# -> Symlinking specific files (and creating their directory in ~/.config) - verbose (?)
# Both, separated.
