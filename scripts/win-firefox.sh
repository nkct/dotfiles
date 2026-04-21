#!/bin/bash
"$DOTFILES_DIR/scripts/win-open.sh" "firefox" "$@"
#if [ -x "/mnt/c/Program Files/Firefox Developer Edition/firefox.exe" ]; then
#  "/mnt/c/Program Files/Firefox Developer Edition/firefox.exe" "$@"
#elif [ -x "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" ]; then
#  "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" "$@"
#else
#  echo "Firefox not found in Windows host" >&2
#  exit 1
#fi
