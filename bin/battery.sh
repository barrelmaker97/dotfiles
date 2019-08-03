#!/bin/bash
linux=/sys/class/power_supply/BAT0/capacity
wsl=/sys/class/power_supply/battery/capacity
echo -e "$(cat $linux $wsl 2> /dev/null)% "
