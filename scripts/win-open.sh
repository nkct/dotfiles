#!/bin/sh
if [ "${IS_WSL:-}" = "1" ]; then
  args=""
  for p in "$@"; do
    # convert path with wslpath -m and strip trailing newline
    wp=$(wslpath -w -- "$p" 2>/dev/null | tr -d '\r\n')
    # if wslpath fails or returns empty, fall back to original argument
    if [ -z "$wp" ]; then
      wp="$p"
    fi
    # escape single quotes for embedding in single-quoted PowerShell string
    wp_esc=$(printf "%s" "$wp" | sed "s/'/''/g")
    args="$args '$wp_esc'"
  done

  powershell.exe -NoProfile -Command "Start-Process$args"
else
  echo "IS_WSL is not set"
  exit 1
fi
