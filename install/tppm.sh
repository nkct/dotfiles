#!/usr/bin/env bash
# Entrypoint for the Trivial Personal Package Manager
# Any file in this directory, which ends with '.pkg.sh' is taken to be an installation script
# Installation scripts must expose two functions: info and install, as well as a _DEPS array variable

set -euo pipefail
cd "$(dirname "$0")"

USAGE="tppm --help\n     list\n     info <PKG>\n     install <PKG>\n"

--help() {
  echo -e "$USAGE"
}

list() {
  echo "Avaliable packages:"
  for f in *.pkg.sh; do
    [ -e "$f" ] || continue
    echo " - ${f%.pkg.sh}"
  done
}

info() {
  pkg=$1
  if [ $# -eq 0 ]; then
    echo -e "$USAGE"
    return 0
  fi

  source "./$pkg.pkg.sh"
  info
  echo "Requires: ${_DEPS[@]}"
}

install() {
  pkg=$1
  if [ $# -eq 0 ]; then
    echo -e "$USAGE"
    return 0
  fi

  source "./$pkg.pkg.sh"
  for dep in "${_DEPS[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      printf 'Error: required dependency "%s" not found.\n' "$dep" >&2
      exit 1
    fi
  done

  install
}

cmd="${1:-}"
if declare -F -- "$cmd" >/dev/null; then
  shift
  "$cmd" "$@"
else
  echo "Command '$cmd' not found" >&2
  echo -e "$USAGE"
  exit 2
fi

