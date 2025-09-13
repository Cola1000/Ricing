#!/usr/bin/env bash
SEL="$("${HOME}/.config/rofi/preview_mode.sh" | rofi -modi "preview:${HOME}/.config/rofi/preview_mode.sh" -show preview -theme "${HOME}/.config/rofi/preview-two-col.rasi")"

# Expect rows like "L: firefox" or "R: preview"
case "$SEL" in
#   L:\ *) CMD="${SEL#L: }"; exec "$CMD" ;;
  *) exit 0 ;;
esac
