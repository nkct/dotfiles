#!/usr/bin/env bash
# docker-psp.sh - pretty docker ps with colors and width scaling

# Run docker ps -a with tab-separated fields and capture output/status
DOCKER_OUT=$(docker ps -a --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.RunningFor}}' 2>&1)
DOCKER_STATUS=$?

# If docker ps failed, print original output and exit with same status
if [ $DOCKER_STATUS -ne 0 ]; then
  printf '%s\n' "$DOCKER_OUT"
  exit $DOCKER_STATUS
fi

# Terminal width (fallback 80)
COLS=$(tput cols 2>/dev/null || echo 80)
# Minimums for columns
MIN_ID=12
MIN_NAME=14
MIN_IMAGE=14
MIN_STATUS=12
MIN_PORTS=12
MIN_AGE=8

# Gaps between columns (spaces)
GAP=2
# Compute minimum total width
MIN_TOTAL=$((MIN_ID + MIN_NAME + MIN_IMAGE + MIN_STATUS + MIN_PORTS + MIN_AGE + GAP*5))

# If terminal is small, use minimums; else distribute extra width mainly to NAME and IMAGE
if [ "$COLS" -le "$MIN_TOTAL" ]; then
  id_w=$MIN_ID; name_w=$MIN_NAME; image_w=$MIN_IMAGE
  status_w=$MIN_STATUS; ports_w=$MIN_PORTS; age_w=$MIN_AGE
else
  extra=$((COLS - MIN_TOTAL))
  add_name=$(( extra * 50 / 100 ))
  add_image=$(( extra * 30 / 100 ))
  add_ports=$(( extra * 20 / 100 ))
  id_w=$MIN_ID
  name_w=$((MIN_NAME + add_name))
  image_w=$((MIN_IMAGE + add_image))
  status_w=$MIN_STATUS
  ports_w=$((MIN_PORTS + add_ports))
  age_w=$MIN_AGE
fi

# ANSI colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36;1m"
RESET="\033[0m"

# Helper awk to format and color; simple truncation with ellipsis
printf "%b" ""
printf "%s\n" "" | awk 'END{}' >/dev/null 2>&1  # ensure awk exists

printf "%b" "$CYAN"
printf "%-*s  %-*s  %-*s  %-*s  %-*s  %-*s\n" \
  "$id_w" "CONTAINER ID" "$name_w" "NAMES" "$image_w" "IMAGE" "$status_w" "STATUS" "$ports_w" "PORTS" "$age_w" "AGE"
printf "%b" "$RESET"

# Process each line
printf '%s\n' "$DOCKER_OUT" | awk -F"\t" \
  -v idw="$id_w" -v namew="$name_w" -v imgw="$image_w" -v stw="$status_w" \
  -v portw="$ports_w" -v agew="$age_w" \
  -v RED="$RED" -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v RESET="$RESET" \
  'function trunc(s,n){ if(length(s)>n) return substr(s,1,n-1) "…"; return s }
   {
     id = trunc($1, idw)
     name = trunc($2, namew)
     image = trunc($3, imgw)
     status = trunc($4, stw)
     ports = trunc($5, portw)
     age = trunc($6, agew)

     # color choice
     if ($4 ~ /^Up/) col = GREEN
     else if ($4 ~ /^Exited/ || $4 ~ /^Exit/) col = RED
     else col = YELLOW

     # print: only wrap status in color codes to avoid escaping the whole line
     printf "%-*s  %-*s  %-*s  %s%-*s%s  %-*s  %-*s\n", \
       idw, id, namew, name, imgw, image, col, stw, status, RESET, portw, ports, agew, age
   }'

exit 0

