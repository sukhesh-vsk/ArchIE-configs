#!/bin/sh
# Simple script to show the cpu temp formatted to be shown in polybar

# Get the temperature readings
temp0=$(sensors | grep 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//')
temp2=$(sensors | grep 'Core 2' | awk '{print $3}' | sed 's/+//;s/°C//')

# Use the maximum temperature for display
temp=$(echo "$temp0" "$temp2" | awk '{print ($1>$2) ? $1 : $2}')

if [ 1 -eq "$(echo "$temp > 80" | bc)" ]; then
    printf "%%{F#BF616A}"
elif [ 1 -eq "$(echo "$temp > 60" | bc)" ]; then
    printf "%%{F#e9b189}";
elif [ 1 -eq "$(echo "$temp > 15" | bc)" ]; then
    printf "%%{F#F3A3BC}";    
fi
echo " $temp"°C
