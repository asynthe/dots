#! /usr/bin/env bash

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

# Determine destination path based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  dest_path="/Users/$(whoami)/.config"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  dest_path="/home/$(whoami)/.config"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

echo "Detected OS: $OSTYPE"
echo "Dotfiles will be symlinked to: $dest_path"

# Ensure .config directory exists
mkdir -p "$dest_path"

configs=(
  "alacritty"
  #"bash" # TODO Fix
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
  #"zsh" # TODO Fix
)

# Create directories and symlink files
for config in "${configs[@]}"; do
  src="$HOME/dots/config/$config"
  target="$dest_path/$config"

  echo "Symlinking $config..."
  sleep 0.2
  
  if [[ -d "$src" ]]; then
    ln -sfn "$src" "$target"
  else
    mkdir -p "$(dirname "$target")"
    ln -sf "$src" "$target"
  fi
done

sleep 1
echo "-------------- Finished! --------------"

# Create directories and symlink files
#for config in "${configs[@]}"; do
#  src="$HOME/dots/config/$config"
#  target="$dest_path/$config"
#  
#  if [[ -d "$src" ]]; then
#    ln -sfn "$src" "$target"
#  else
#    mkdir -p "$(dirname "$target")"
#    ln -sf "$src" "$target"
#  fi
#done
#ln -sf "$HOME"/dots/config/alacritty/alacritty.toml "$HOME"/.config/alacritty/alacritty.toml
#ln -sf "$HOME"/dots/config/cava/config "$HOME"/.config/cava/config
#ln -sf "$HOME"/dots/config/direnv/direnv.toml "$HOME"/.config/direnv/direnv.toml
#ln -sf "$HOME"/dots/config/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf
#ln -sf "$HOME"/dots/config/mako/config "$HOME"/.config/mako/config
#ln -sf "$HOME"/dots/config/mpd "$HOME"/.config/mpd # TODO Fix `mpd_bk.conf` then symlink uniquely.
#ln -sf "$HOME"/dots/config/mpv/input.conf "$HOME"/.config/mpv/input.conf
#ln -sf "$HOME"/dots/config/mpv/mpv.conf "$HOME"/.config/mpv/mpv.conf
#ln -sf "$HOME"/dots/config/ncmpcpp/bindings "$HOME"/.config/ncmpcpp/bindings
#ln -sf "$HOME"/dots/config/ncmpcpp/config "$HOME"/.config/ncmpcpp/config
#ln -sf "$HOME"/dots/config/nushell/config.nu "$HOME"/.config/nushell/config.nu
#ln -sf "$HOME"/dots/config/nushell/env.nu "$HOME"/.config/nushell/env.nu
#ln -sf "$HOME"/dots/config/rasi/config.rasi "$HOME"/.config/rasi/config.rasi
#ln -sf "$HOME"/dots/config/sioyek/keys_user.config "$HOME"/.config/sioyek/keys_user.config
#ln -sf "$HOME"/dots/config/starship/starship.toml "$HOME"/.config/starship.toml
#ln -sf "$HOME"/dots/config/tmux/tmux.conf "$HOME"/.config/tmux/tmux.conf
#ln -sf "$HOME"/dots/config/waybar/config.jsonc "$HOME"/.config/waybar/config.jsonc
#ln -sf "$HOME"/dots/config/waybar/style.css "$HOME"/.config/waybar/style.css
#ln -sf "$HOME"/dots/config/wayfire/wayfire.ini "$HOME"/.config/wayfire/wayfire.ini
#ln -sf "$HOME"/dots/config/wezterm/config.lua "$HOME"/.config/wezterm/config.lua
#ln -sf "$HOME"/dots/config/wofi/config "$HOME"/.config/wofi/config
#ln -sf "$HOME"/dots/config/wofi/style.css "$HOME"/.config/wofi/style.css
#ln -sf "$HOME"/dots/config/xmobar/xmobarrc "$HOME"/.config/xmobbar/xmobarrc
#ln -sf "$HOME"/dots/config/xmonad/xmonad.hs "$HOME"/.config/xmonad/xmonad.hs
#ln -sf "$HOME"/dots/config/yazi/theme.toml "$HOME"/.config/yazi/theme.toml
#ln -sf "$HOME"/dots/config/yazi/yazi.toml "$HOME"/.config/yazi/yazi.toml
#ln -sf "$HOME"/dots/config/zathura/zathurarc "$HOME"/.config/zathura/zathurarc

# TODO Fix
#ln -sf "$HOME"/dots/config/zsh "$HOME"/.config/zsh

# Working
#ln -sf "$HOME"/dots/config/nvim "$HOME"/.config/nvim
#ln -sf "$HOME"/dots/config/wezterm "$HOME"/.config/wezterm

# Hyprland (if ~/.config/hypr exists then delete or set a y/n for overwriting)
#ln -sf "$HOME"/dots/config/hypr "$HOME"/.config/hypr

# Emacs (if ~/.emacs.d exist then delete or set a y/n for overwriting
#ln -sf "$HOME"/dots/config/emacs "$HOME"/.config/emacs

#echo "For"
# FIX: for folder instead (?)
#for file in ~/sync/dots/dots/*; do
  #target="$dest_path/$(basename "$file")"
  #
  #if [ -L "$target" ]; then
    #echo "Updating existing symlink: $target"
    #rm "$target"
    #ln -s "$file" "$target"
    #echo "Symlink updated for: $target"
  #elif [ -e "$target" ]; then
    #echo "File already exists (not a symlink): $target. Skipping."
  #else
    #ln -s "$file" "$target"
    #echo "Symlink created for: $target"
  #fi
#done
