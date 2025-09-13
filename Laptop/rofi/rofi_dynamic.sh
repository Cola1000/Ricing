#!/usr/bin/env bash

# Use the custom modi. Typing filters both columns; selecting "L: <cmd>" runs it.
# Selecting the right-column row does nothing (it’s only for preview).

rofi -modi "preview:${HOME}/.config/rofi/preview_mode.sh" \
     -show preview \
     -theme "${HOME}/.config/rofi/preview-two-col.rasi" \
     -matching fuzzy -kb-accept-entry "Return" -kb-row-down "Down" -kb-row-up "Up" \
     -no-click-to-exit
