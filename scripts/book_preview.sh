#!/usr/bin/env bash
# Cover preview for the `book` fzf picker (see $ZDOTDIR/.zsh_functions).
# Renders page 1 of a PDF to a cached PNG and draws it with whatever image
# protocol the terminal speaks. Falls back to plain text when it can't draw.
set -uo pipefail

file=${1:-}
[ -f "$file" ] || { echo "not a file: $file"; exit 0; }

cols=${FZF_PREVIEW_COLUMNS:-${COLUMNS:-40}}
lines=${FZF_PREVIEW_LINES:-${LINES:-20}}

info() {
  printf '%s\n' "${file##*/}"
  printf '%s\n' "$(du -h -- "$file" | cut -f1)  $(date -r "$file" '+%Y-%m-%d')"
  command -v pdfinfo >/dev/null 2>&1 && pdfinfo -- "$file" 2>/dev/null |
    grep -E '^(Title|Author|Pages)' | sed 's/  */ /g'
}

# Non-PDFs get no cover render; just the text card.
case "${file,,}" in
  *.pdf) ;;
  *) info; exit 0 ;;
esac

if ! command -v pdftoppm >/dev/null 2>&1; then
  info
  echo
  echo "(no cover: install poppler_utils for pdftoppm)"
  exit 0
fi

# Cache key includes mtime and size, so a replaced file re-renders.
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/book-covers
mkdir -p "$cache_dir"
key=$(printf '%s' "$(stat -c '%n %Y %s' -- "$file")" | sha1sum | cut -d' ' -f1)
cover=$cache_dir/$key.png

if [ ! -s "$cover" ]; then
  pdftoppm -png -singlefile -f 1 -l 1 -scale-to-x 900 -scale-to-y -1 \
    -- "$file" "${cover%.png}" >/dev/null 2>&1 || { info; exit 0; }
fi

backend=${BOOK_PREVIEW_BACKEND:-auto}
if [ "$backend" = auto ]; then
  if [ -n "${TMUX:-}" ]; then
    backend=chafa                      # kitty graphics needs passthrough in tmux
  elif [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM_PROGRAM:-}" = ghostty ] ||
       case "${TERM:-}" in *kitty*|*ghostty*) true ;; *) false ;; esac; then
    backend=kitty
  else
    backend=chafa
  fi
fi

draw_kitty() {
  # --unicode-placeholder keeps the image anchored to the preview window as fzf
  # redraws it. The trailing sed collapses the bare reset line kitty emits,
  # which fzf would otherwise read as an extra scrolled line.
  local out
  out=$(kitty +kitten icat --clear --transfer-mode=memory --unicode-placeholder \
          --stdin=no --place="${cols}x${lines}@0x0" -- "$cover" 2>/dev/null |
        sed '$d' | sed $'$s/$/\e[m/')
  [ -n "$out" ] || return 1
  printf '%s\n' "$out"
}

if [ "$backend" = kitty ] && command -v kitty >/dev/null 2>&1; then
  draw_kitty && exit 0
fi

if command -v chafa >/dev/null 2>&1; then
  chafa_args=(--size="${cols}x${lines}" --align=center)
  [ -n "${TMUX:-}" ] && chafa_args+=(--passthrough=tmux)
  chafa "${chafa_args[@]}" -- "$cover" && exit 0
fi

info
