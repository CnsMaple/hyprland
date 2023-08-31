#!/bin/bash

# take shots
shotnow() {
    grim - | swappy -f -
}

shotwin() {
	w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
	w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
	grim -g "$w_pos $w_size" - | swappy -f -
}

shotarea() {
	grim -g "$(slurp)" - | swappy -f -
}

if [[ "$1" == "--now" ]]; then
	shotnow
elif [[ "$1" == "--win" ]]; then
	shotwin
elif [[ "$1" == "--area" ]]; then
	shotarea
else
	echo -e "Available Options : --now --win --area"
fi

exit 0
