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

ln -sf "$HOME"/dots/config/ncmpcpp/config "$HOME"/.config/ncmpcpp/config
ln -sf "$HOME"/dots/config/ncmpcpp/bindings "$HOME"/.config/ncmpcpp/bindings

# Working
ln -sf "$HOME"/dots/config/nvim "$HOME"/.config/nvim
ln -sf "$HOME"/dots/config/wezterm "$HOME"/.config/wezterm

# Emacs (if ~/.emacs.d exist then delete or set a y/n for overwriting
ln -sf "$HOME"/dots/config/emacs "$HOME"/.config/emacs

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

sleep 1
echo "-------------- Finished! --------------"
