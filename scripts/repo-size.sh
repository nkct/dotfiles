#!/usr/bin/env bash
set -euo pipefail

# project_size.sh (progress + optional snapshots)
# Usage:
#   ./project_size.sh [--git-only] [--code-only] [--top N] [--exclude DIR]... [--snapshot] [--snapshot-every N]
#
# --snapshot        : enable periodic snapshot of top extensions (off by default)
# --snapshot-every N: snapshot frequency (default 1000 processed files)

git_only=false
code_only=false
TOP=30
EXTRA_EXCLUDES=()

# progress / snapshot knobs
MIN_UPDATE=100           # always update progress at least every MIN_UPDATE files
SNAPSHOT_ENABLED=false
SNAPSHOT_EVERY=1000      # effective only when --snapshot is passed

# parse args
while (( $# )); do
  case "$1" in
    --git-only) git_only=true; shift ;;
    --code-only) code_only=true; shift ;;
    --top) TOP="$2"; shift 2 ;;
    --top=*) TOP="${1#*=}"; shift ;;
    --exclude) EXTRA_EXCLUDES+=("$2"); shift 2 ;;
    --exclude=*) EXTRA_EXCLUDES+=("${1#*=}"); shift ;;
    --snapshot) SNAPSHOT_ENABLED=true; shift ;;
    --snapshot-every) SNAPSHOT_EVERY="$2"; shift 2 ;;
    --snapshot-every=*) SNAPSHOT_EVERY="${1#*=}"; shift ;;
    -h|--help)
      cat <<'USAGE'
Usage: project_size.sh [--git-only] [--code-only] [--top N] [--exclude DIR]... [--snapshot] [--snapshot-every N]

--git-only         : count only git-tracked files (if inside git repo)
--code-only        : count only a whitelist of "code" extensions / filenames
--top N            : show top N extensions by lines (default 30)
--exclude DIR      : add directory to exclude (can be repeated)
--snapshot         : enable periodic snapshot of top extensions (off by default)
--snapshot-every N : snapshot frequency in processed files (default 1000)
USAGE
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

# defaults to exclude from search (relative paths)
EXCLUDES=(.git node_modules vendor dist build .cache .next .gradle target .venv)

for e in "${EXTRA_EXCLUDES[@]}"; do
  EXCLUDES+=("$e")
done

IGNORE_EXT=( phar pack png jpg jpeg gif bmp ico ttf woff woff2 eot zip tar gz bz2 jar class o so exe dll bin db sqlite min map pyc svg mo )
IGNORE_NAMES=( .gitignore .gitattributes .nojekyll .DS_Store )

CODE_WHITELIST=( c cpp h hpp py rb go rs java kt kts swift cs ts tsx jsx js php html htm css scss less sh bash zsh ksh pl lua scala r hs erl ex exs el lisp )
CODE_WHITELIST+=( xml yml yaml json md sql Dockerfile Makefile )
KNOWN_NOEXT_AS_CODE=( Dockerfile Makefile )

declare -A files_count
declare -A lines_count

total_files=0
total_lines=0

in_array() {
  local needle="$1"; shift
  for i in "$@"; do [[ "$i" == "$needle" ]] && return 0; done
  return 1
}

process_file() {
  local file="$1"
  [[ -f "$file" ]] || return

  local base
  base="$(basename -- "$file")"

  if in_array "$base" "${IGNORE_NAMES[@]}"; then
    return
  fi

  local ext
  if [[ "$base" == .*.* ]]; then
    ext="${base##*.}"
  elif [[ "$base" == *.* ]]; then
    ext="${base##*.}"
  else
    ext="(noext)"
  fi

  if [[ "$ext" == "(noext)" ]] && in_array "$base" "${KNOWN_NOEXT_AS_CODE[@]}"; then
    ext="$base"
  fi

  if $code_only; then
    if [[ "$ext" == "(noext)" ]]; then
      if ! in_array "$base" "${KNOWN_NOEXT_AS_CODE[@]}"; then
        return
      fi
    else
      if ! in_array "$ext" "${CODE_WHITELIST[@]}"; then
        return
      fi
    fi
  fi

  if [[ "$ext" != "(noext)" ]] && in_array "$ext" "${IGNORE_EXT[@]}"; then
    return
  fi

  local l
  l=$(wc -l < "$file" 2>/dev/null || echo 0)
  l=${l//[!0-9]/}
  l=${l:-0}

  files_count["$ext"]=$(( ${files_count["$ext"]:-0} + 1 ))
  lines_count["$ext"]=$(( ${lines_count["$ext"]:-0} + l ))
  total_files=$(( total_files + 1 ))
  total_lines=$(( total_lines + l ))
}

# build find command (array) with excludes
build_find_cmd() {
  local -n _out=$1
  _out=(find . -type f)
  for e in "${EXCLUDES[@]}"; do
    _out+=(-not -path "./$e/*")
  done
  _out+=(-print0)
}

# get total number of files to process (NUL-safe)
count_files_from_find() {
  local -n _cmd=$1
  "${_cmd[@]}" | tr -cd '\0' | wc -c
}

# Counting files upfront so we can show percentages
if $git_only && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  total_to_process=$(git ls-files -z | tr -cd '\0' | wc -c)
  source_cmd_type="git"
else
  declare -a FIND_CMD
  build_find_cmd FIND_CMD
  total_to_process=$(count_files_from_find FIND_CMD)
  source_cmd_type="find"
fi

if [[ "${total_to_process:-0}" -eq 0 ]]; then
  echo "No files found (after excludes). Nothing to do."
  exit 0
fi

# determine update cadence dynamically
update_every=$(( total_to_process / 100 ))   # aim ~100 updates
if (( update_every < MIN_UPDATE )); then
  update_every=$MIN_UPDATE
fi

processed=0
start_ts=$(date +%s)
last_snapshot=0

# helper to print inline progress (overwrites same line)
print_progress() {
  local proc="$1"
  local total="$2"
  local elapsed=$(( $(date +%s) - start_ts ))
  local pct=$(( proc * 100 / total ))
  printf "\rProcessed: %6d / %6d (%3d%%)  elapsed: %3ds" "$proc" "$total" "$pct" "$elapsed"
}

# helper to show small snapshot of top 5 extensions by lines
print_snapshot() {
  echo
  echo "Snapshot (top 5 by lines):"
  for ext in "${!lines_count[@]}"; do
    printf '%s\t%s\t%s\n' "${lines_count[$ext]}" "${files_count[$ext]}" "$ext"
  done | sort -nr | head -n 5 | awk -F'\t' '{printf "  %s: %s files — %s lines\n", $3, $2, $1}'
  echo
}

# Main loop (NUL-safe). Use process-substitution; loop runs in current shell so associative arrays persist.
if [[ "$source_cmd_type" == "git" ]]; then
  while IFS= read -r -d '' f; do
    process_file "$f"
    processed=$((processed + 1))

    if (( processed % update_every == 0 )); then
      print_progress "$processed" "$total_to_process"
    fi

    if $SNAPSHOT_ENABLED && (( processed - last_snapshot >= SNAPSHOT_EVERY )); then
      print_progress "$processed" "$total_to_process"
      print_snapshot
      last_snapshot=$processed
    fi
  done < <(git ls-files -z)
else
  declare -a FIND_CMD
  build_find_cmd FIND_CMD
  while IFS= read -r -d '' f; do
    process_file "$f"
    processed=$((processed + 1))

    if (( processed % update_every == 0 )); then
      print_progress "$processed" "$total_to_process"
    fi

    if $SNAPSHOT_ENABLED && (( processed - last_snapshot >= SNAPSHOT_EVERY )); then
      print_progress "$processed" "$total_to_process"
      print_snapshot
      last_snapshot=$processed
    fi
  done < <("${FIND_CMD[@]}")
fi

# final progress line (move to new line)
print_progress "$processed" "$total_to_process"
echo
echo

# final report (same as your settled script)
echo "Overall Total files: $total_files   Total lines: $total_lines"
echo
echo "Counts by file type (sorted by total lines):"
for ext in "${!lines_count[@]}"; do
  printf '%s\t%s\t%s\n' "${lines_count[$ext]}" "${files_count[$ext]}" "$ext"
done | sort -nr | awk -F'\t' -v top="$TOP" 'NR<=top {printf "Extension .%s: %s files — %s lines\n", $3, $2, $1}'

echo
echo "Note: excluded dirs: ${EXCLUDES[*]}"
echo "Ignored extensions by default: ${IGNORE_EXT[*]}"
echo "Ignored filenames by default: ${IGNORE_NAMES[*]}"
if $code_only; then
  echo "Mode: CODE-ONLY (whitelist): ${CODE_WHITELIST[*]}"
fi

