#!/bin/bash
rofi -show combi -sep $'\t' -display-columns 1 \
     -combi-modes "drun,files" \
     -modes "combi,drun,files:$HOME/.config/rofi/file.sh" \
     -disable-history \
     -theme $HOME/.config/rofi/config.rasi \
     -no-sort \
     -show-icons false \