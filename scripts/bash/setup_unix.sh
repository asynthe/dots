#! /usr/bin/env bash

# TODO Zsh setup
# symlink to .zshenv in dots/config/zsh?

# TODO Can I run the flake from inside a Windows folder?
# TODO If WSL is detected, then add a symlink to `/mnt/c/Users/ben/Desktop` to `$HOME`.
# -> Ask what the Windows username is?

# ASCII
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
  echo "Unsupported OS: $OSTYPE"
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

configs=(
  "alacritty"
  "bash" # TODO Haven't got a config yet, but this can do.
  "cava"
  "direnv"
  "emacs"
  "ghostty"
  "hypr"
  "kitty"
  "mako"
  "mpd"
  "mpv"
  "ncmpcpp"
  "nushell"
  "nvim"
  "rofi"
  "sioyek"
  "starship"
  "tmux"
  "vis"
  "waybar"
  "wayfire"
  "wezterm"
  "wofi"
  "xmobar"
  "xmonad"
  "yazi"
  "zathura"
  "zsh" # TODO NixOS: Seems like Home Manager sets up a config
)       # delete it and set zsh configuration again.

# Create directories and symlink files
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
