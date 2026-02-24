#!/bin/bash
if pgrep -x "rofi" > /dev/null; then
    pkill -x "rofi"
    exit 0
fi

rofi -show combi -sep $'\t' -display-columns 1 \
     -combi-modes "drun,files" \
     -modes "combi,drun,files:$HOME/.config/rofi/file.sh" \
     -disable-history \
     -theme $HOME/.config/rofi/config.rasi \
     -no-sort \
     -show-icons true \
     -click-to-exit true &
