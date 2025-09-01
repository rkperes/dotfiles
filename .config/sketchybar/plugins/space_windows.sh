#!/bin/bash

echo "called $SENDER $1 focused:$FOCUSED_WORKSPACE prev:$PREV_WORKSPACE src:$SOURCE_WORKSPACE tgt:$TARGET_WORKSPACE"

FOCUSED_WORKSPACE=${FOCUSED_WORKSPACE:-"$(aerospace list-workspaces --focused)"}

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on
else
    sketchybar --set $NAME background.drawing=off
fi

if [ "$SENDER" = "aerospace_monitor_change" ]; then
  sketchybar --set space."$FOCUSED_WORKSPACE" display="$TARGET_MONITOR"
  exit 0
fi

# If app is moved to another workspace, redraw target workspace.
if [ "$SENDER" = "aerospace_app_change" ]; then
  # If workspace changes automatically with the app,
  # switch these two values.

  FOCUSED_WORKSPACE=$SOURCE_WORKSPACE
  WS=$TARGET_WORKSPACE

  prevapps=$(aerospace list-windows --workspace "$WS" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  if [ "${prevapps}" != "" ]; then
    icon_strip=" "
    while read -r app; do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
    done <<<"${prevapps}"
    sketchybar --set space.$WS icon.color="0xffffffff"
    sketchybar --set space.$WS label="$icon_strip"
  else
    sketchybar --set space.$WS icon.color="0x44ffffff"
  fi
fi

apps=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
sketchybar --set space.$FOCUSED_WORKSPACE drawing=on
icon_strip=" "
if [ "${apps}" != "" ]; then
  while read -r app; do
    icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
  done <<<"${apps}"
  sketchybar --set space.$FOCUSED_WORKSPACE icon.color="0xffffffff"
else
  sketchybar --set space.$FOCUSED_WORKSPACE icon.color="0x44ffffff"
  icon_strip=""
fi
sketchybar --set space.$FOCUSED_WORKSPACE label="$icon_strip"
