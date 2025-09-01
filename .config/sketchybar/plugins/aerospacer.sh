#!/bin/bash

<<<<<<< HEAD
echo "called with $1"
echo "$FOCUSED_WORKSPACE"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on
else
    sketchybar --set $NAME background.drawing=off
fi
=======
echo "called $SENDER $1 focused:$FOCUSED_WORKSPACE prev:$PREV_WORKSPACE src:$SOURCE_WORKSPACE tgt:$TARGET_WORKSPACE"

# if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     sketchybar --set $NAME background.drawing=on
# else
#     sketchybar --set $NAME background.drawing=off
# fi
>>>>>>> 97ad7e95cff08263eabbeaf1ec21578298c90f8e

