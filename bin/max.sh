#!/bin/bash
# Max brightness when run without arguments
if [ "$#" -eq 0 ]; then
	sudo cat /sys/class/backlight/intel_backlight/max_brightness | sudo tee /sys/class/backlight/intel_backlight/brightness
	exit 0
fi
