#!/bin/bash
# Max brightness when run without arguments
if [ "$#" -eq 0 ]; then
	sudo tee /sys/class/backlight/intel_backlight/brightness < /sys/class/backlight/intel_backlight/max_brightness
	exit 0
fi
