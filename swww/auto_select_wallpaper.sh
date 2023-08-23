#!/bin/bash

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script is in bash (not posix shell), because the RANDOM variable
# we use is not defined in posix

# if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
# 	echo "Usage:
# 	$0 <dir containing images>"
# 	exit 1
# fi

dir="$HOME/czyworkspace/wallpaper"

if [[ -e "$dir" ]]; then
    echo "have wallpaper path: $dir"
else
    dir="$HOME/.config/swww/wallpaper"
fi

if [[ -e "$dir" ]]; then
    echo "have wallpaper path: $dir"
else
    exit 1
fi

# Edit below to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=2

# This controls (in seconds) when to switch to the next image
INTERVAL=300

swww init
while true; do
	find "$dir" -type f \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			swww img "$img"
			sleep $INTERVAL
		done
done
