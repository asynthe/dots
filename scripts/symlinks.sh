echo "-------------- Symlink script for dotfiles --------------"
sleep 2

if [[ "$OSTYPE" == "darwin"* ]]; then
  dest_path="/Users/$(whoami)/.config"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  dest_path="/home/$(whoami)/.config"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi


echo "For"
for file in ~/sync/dots/dots/*; do
  target="$dest_path/$(basename "$file")"
  
  if [ -L "$target" ]; then
    echo "Updating existing symlink: $target"
    rm "$target"
    ln -s "$file" "$target"
    echo "Symlink updated for: $target"
  elif [ -e "$target" ]; then
    echo "File already exists (not a symlink): $target. Skipping."
  else
    ln -s "$file" "$target"
    echo "Symlink created for: $target"
  fi
done

sleep 2
echo "-------------- Finished! --------------"
