#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
get_controls

GAMEDIR="/$directory/ports/spectralslash"

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export XDG_CONFIG_HOME="$GAMEDIR/conf"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CONFIG_HOME"

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

GAME_FILE="SpectralSlash.exe"
LAUNCH_FILE="SpectralSlash"

if [ -f "$GAME_FILE" ]; then
  pauselua_file="Engine/PauseMenu.lua"
  ./bin/7za x "$GAME_FILE" "$pauselua_file"
  sed -i 's/love\.graphics\.newFont("Fonts\/monogram\.ttf", 16)/monogram/' "$pauselua_file"
  ./bin/7za u -mx0 -aoa "$GAME_FILE" "$pauselua_file"
  rm -rf "Engine"
  
  mv "$GAME_FILE" "$LAUNCH_FILE"
fi

$GPTOKEYB "love" &
./bin/love "$LAUNCH_FILE"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0