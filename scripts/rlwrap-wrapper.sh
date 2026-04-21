#!/usr/bin/env bash
# Usage: ./rlwrap-wrapper.sh <command> [args...]

if command -v rlwrap >/dev/null 2>&1; then
  rlwrap "$@"
else
  echo "Install rlwrap for improved CLI navigation"
  "$@"
fi

