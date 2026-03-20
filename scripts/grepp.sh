#!/bin/bash

# Default lines argument
lines=3

# Function to display usage information
usage() {
    echo "Usage: $(basename $0) [OPTIONS] PATTERN [FILE...]"
    echo "Options:"
    echo "  --lines N     Set the number of lines to display (default is 3)"
    echo "  -h, --help    Display this help message"
}

# Parse command-line options
while [[ "$1" == --* ]]; do
    case "$1" in
        --lines)
            lines="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Ensure at least a pattern is provided
if [ $# -lt 1 ]; then
    echo "Error: PATTERN is required."
    usage
    exit 1
fi

# Get the pattern and remaining arguments (files)
pattern="$1"
shift
files=("$@")

# Run grep with -Iirn options and cut
#cut_chars=`expr $COLUMNS \* $lines` 
COLUMNS=$(tput cols)
cut_chars=$(( COLUMNS * lines ))
grep --color=always -Iirn "$pattern" --exclude-dir=".*" "${files[@]}" | cut -c 1-"$cut_chars"

