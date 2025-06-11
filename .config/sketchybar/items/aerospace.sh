#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change
for sid in $(aerospace list-workspaces --all); do
	echo "$CONFIG_DIR/plugins/aerospacer.sh $sid"
    sketchybar --add item space."$sid" left \
        --subscribe space."$sid" aerospace_workspace_change \
        --set space."$sid" \
        background.color=0x44ffffff \
        background.corner_radius=5 \
        background.height=20 \
        background.drawing=off \
        label.font.size=10.0 \
        label="$sid" \
        click_script="aerospace workspace $sid" \
		script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
done
