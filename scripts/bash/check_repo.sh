check_repo() {
  if [ -n "$TERMUX_VERSION" ]; then
    REPOS=(
      "$HOME/dots:dots"
      "$HOME/notes:notes"
      "$HOME/sakuhin:sakuhin"
    )
  else
    REPOS=(
      "/home/meow/ben/pass:pass"
      "/home/meow/dots:dots"
      "/home/meow/notes:notes"
      "/home/meow/sakuhin:sakuhin"
    )
  fi
  local yellow='\033[1;33m'
  local red='\033[0;31m'
  local nc='\033[0m'
  for entry in "${REPOS[@]}"; do
    repo="${entry%%:*}"
    name="${entry##*:}"
    [ ! -d "$repo" ] && continue
    cd "$repo" || continue
    if command -v jj &>/dev/null && [ -d ".jj" ]; then
      empty=$(jj log -r '@' --no-graph -T 'empty' 2>/dev/null)
      pending=$(jj log -r '@- ~ remote_bookmarks()' --no-graph -T 'change_id' 2>/dev/null | wc -c)
      [ "$empty" != "true" ] && echo -e "  ${yellow}[✎]${nc} Uncommitted changes in '$name'"
      [ "$pending" -gt 1 ] && echo -e "  ${red}[⚠]${nc} Unpushed changes in '$name'"
    elif [ -d ".git" ]; then
      uncommitted=$(git status --short 2>/dev/null)
      unpushed=$(git log @{u}.. --oneline 2>/dev/null | wc -l)
      [ -n "$uncommitted" ] && echo -e "  ${yellow}[✎]${nc} Uncommitted changes in '$name'"
      [ "$unpushed" -gt 0 ] && echo -e "  ${red}[⚠]${nc} Unpushed changes in '$name'"
    fi
    cd - > /dev/null
  done
  echo ""
}
check_repo
