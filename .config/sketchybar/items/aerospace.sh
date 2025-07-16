#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change
_EMPTY=$(aerospace list-workspaces --monitor all --empty)
for mid in $(aerospace list-monitors --format "%{monitor-id}"); do
    sketchybar --add item monitor."$mid" left \
        --set monitor."$mid" \
        background.color=$BACKGROUND_COLOR_HL1 \
        background.corner_radius=0 \
        background.drawing=on \
        label.font.size=10.0 \
        label="󰍹 $mid" \

        for sid in $(aerospace list-workspaces --monitor $mid); do
                echo "$CONFIG_DIR/plugins/aerospacer.sh $sid"
                _IS_EMPTY=$(echo "$_EMPTY" | grep -w "$sid")
                _COLOR=$([[ -z "$_IS_EMPTY" ]] && echo $WHITE || echo $GREY )
                sketchybar --add item space."$sid" left \
                        --subscribe space."$sid" aerospace_workspace_change \
                        --set space."$sid" \
                        background.color=$BACKGROUND_COLOR_HL2 \
                        background.corner_radius=2 \
                        background.height=20 \
                        background.drawing=off \
                        label.font.size=10.0 \
                        label.padding_left=0 \
                        label.padding_right=5 \
                        label.color=$_COLOR \
                        label="$sid" \
                        click_script="aerospace workspace $sid" \
                        script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
        done
done
