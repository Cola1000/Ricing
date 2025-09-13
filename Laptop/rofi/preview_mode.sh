#!/usr/bin/env bash
# Outputs two "columns": left = run entries, right = one big-icon preview row.
# The "icon" of the preview row changes with the current query.

IMGDIR="$HOME/.config/rofi/images"
QUERY="${ROFI_INPUT:-$1}"

pick_image() {
  case "$QUERY" in
    # firefox*) echo "$IMGDIR/firefox.png" ;;
    # code*|vsc*|vscode*|codium*) echo "$IMGDIR/code.png" ;;
    *) echo "$IMGDIR/sleep.gif" ;;
  esac
}

# 1) Left column: real run entries (read from PATH)
# We’ll list unique executables, trimmed.
PATH_ITEMS=$(compgen -c | awk '!seen[$0]++' | head -n 400)

# 2) Right column: one special "preview" row with a big icon
PREVIEW_ICON="$(pick_image)"

# Rofi rows: we’ll prefix left-column items with "L: " and add one "R: " row
# with \0icon metadata to set the image for that row.
# Rofi will just show them; theme will split into two columns.

{
  # Left column items (no icons here to keep it clean)
  while IFS= read -r cmd; do
    printf "L: %s\n" "$cmd"
  done <<< "$PATH_ITEMS"

  # Right column: one row whose icon is the preview
  printf "R: preview\0icon\x1f%s\n" "$PREVIEW_ICON"
} 
