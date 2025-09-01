#!/usr/bin/env bash

## install app font:
# https://github.com/kvndrsslr/sketchybar-app-font/releases

sketchybar --add event aerospace_app_change
sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_monitor_change

_EMPTY=$(aerospace list-workspaces --monitor all --empty)
for sid in $(aerospace list-workspaces --all); do
  _IS_EMPTY=$(echo "$_EMPTY" | grep -w "$sid")
  _COLOR=$([[ -z "$_IS_EMPTY" ]] && echo "0xffffffff" || echo "0x44ffffff" )
  _BG=$([ "$sid" = "1" ] && "off" || "on")
  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_app_change aerospace_workspace_change \
    --set space.$sid \
	background.color=0x44ffffff \
	background.corner_radius=2 \
	background.height=20 \
	background.drawing=$_BG \
    icon="$_BG $sid" \
    icon.padding_left=5 \
    icon.shadow.distance=2 \
    icon.shadow.color=0xA0000000 \
	icon.color=$_COLOR \
    label.font="sketchybar-app-font:Regular:12.0" \
    label.padding_right=20 \
    label.padding_left=0 \
    label.y_offset=-1 \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/space_windows.sh $sid"
done

# Load Icons on startup
for mid in $(aerospace list-monitors | cut -c1); do
  for sid in $(aerospace list-workspaces --monitor $mid --empty no); do
  apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  sketchybar --set space.$sid drawing=on

  icon_strip="  "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon_strip+=" $(${CONFIG_DIR}/plugins/icon_map_fn.sh "$app")"
    done <<<"${apps}"
  else
    icon_strip="-"
  fi
  sketchybar --set space.$sid label="$icon_strip"
  done
done

sketchybar --add item space_separator left \
  --set space_separator icon="~" \
  icon.padding_left=4 \
  label.drawing=off \
  background.drawing=off \
  script="$PLUGIN_DIR/space_windows.sh" \
  --subscribe space_separator aerospace_workspace_change front_app_switched space_windows_change aerospace_monitor_change

# Front app!!
sketchybar --add item front_app left \
  --set front_app icon.drawing=off \
  script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched

## OLD CONFIG
# _EMPTY=$(aerospace list-workspaces --monitor all --empty)
# for mid in $(aerospace list-monitors --format "%{monitor-id}"); do
#     sketchybar --add item monitor."$mid" left \
#         --set monitor."$mid" \
#         background.color=0x22ffffff \
#         background.corner_radius=0 \
#         background.drawing=on \
#         label.font.size=10.0 \
#         label="󰍹 $mid" \
#
#         for sid in $(aerospace list-workspaces --monitor $mid); do
#                 echo "$CONFIG_DIR/plugins/aerospacer.sh $sid"
#                 _IS_EMPTY=$(echo "$_EMPTY" | grep -w "$sid")
#                 _COLOR=$([[ -z "$_IS_EMPTY" ]] && echo "0xffffffff" || echo "0x44ffffff" )
#                 sketchybar --add item space."$sid" left \
#                         --subscribe space."$sid" aerospace_workspace_change \
#                         --set space."$sid" \
#                         background.color=0x44ffffff \
#                         background.corner_radius=2 \
#                         background.height=20 \
#                         background.drawing=off \
#                         label.font.size=10.0 \
#                         label.padding_left=0 \
#                         label.padding_right=5 \
#                         label.color=$_COLOR \
#                         label="$sid" \
#                         click_script="aerospace workspace $sid" \
#                         script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
#         done
# done
