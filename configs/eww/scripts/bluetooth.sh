#!/usr/bin/env bash

toggle() {
  status=$(rfkill -J | jaq -r '.rfkilldevices[] | select(.type == "bluetooth") | .soft' | head -1)

  if [ "$status" = "unblocked" ]; then
    rfkill block bluetooth
  else
    rfkill unblock bluetooth
  fi
}

if [ "$1" = "toggle" ]; then
  toggle
else
  while true; do
    powered=$(bluetoothctl show | rg Powered | cut -f 2- -d ' ')
    status=$(bluetoothctl info)
    name=$(echo "$status" | rg Name | cut -f 2- -d ' ')
    mac=$(echo "$status" | head -1 | awk '{print $2}' | tr ':' '_')

    if [[ "$(echo "$status" | rg Percentage)" != "" ]]; then
      battery="$(upower -i /org/freedesktop/UPower/devices/headset_dev_"$mac" | rg percentage | awk '{print $2}' | cut -f 1 -d '%')%"
    else
      battery=""
    fi

    if [ "$powered" = "yes" ]; then
      if [ "$status" != "Missing device address argument" ]; then
        text="$name"
        icon=""
        color="#89b4fa"
        class="bt-connected"
      else
        icon=""
        text="Disconnected"
        class="bt-disconnected"
      fi
    else
      icon=""
      text="Bluetooth off"
      class=""
    fi

    echo '{ "icon": "'"$icon"'", "battery": "'"$battery"'", "text": "'"$text"'", "color": "'"$color"'", "class": "'"$class"'" }'

    sleep 3
  done
fi
