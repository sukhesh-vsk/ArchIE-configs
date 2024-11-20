#!/bin/bash

print_bytes() {
    if [ "$1" -eq 0 ] || [ "$1" -lt 1000 ]; then
        bytes="0 kB/s"
    elif [ "$1" -lt 1000000 ]; then
        bytes="$(echo "scale=1; $1/1000" | bc -l) kB/s"
    else
        bytes="$(echo "scale=1; $1/1000000" | bc -l) MB/s"
    fi

    echo "$bytes"
}

print_bits() {
    bits=$(( $1 * 8 ))
    if [ "$1" -eq 0 ] || [ "$1" -lt 1000 ]; then
        bits="0 b/s"
    elif [ "$1" -lt 1000000 ]; then
        bits="$(echo "scale=1; $1/1000" | bc -l) Kb/s"
    else
        bits="$(echo "scale=1; $1/1000000" | bc -l) Mb/s"
    fi

    echo "$bits"
}

INTERVAL=3
INTERFACES="enp3s0 wlan0"

declare -A bytes

for interface in $INTERFACES; do
    bytes[past_rx_$interface]="$(cat /sys/class/net/"$interface"/statistics/rx_bytes)"
    bytes[past_tx_$interface]="$(cat /sys/class/net/"$interface"/statistics/tx_bytes)"
done

while true; do
    down=0
    up=0

    for interface in $INTERFACES; do
        bytes[now_rx_$interface]="$(cat /sys/class/net/"$interface"/statistics/rx_bytes)"
        bytes[now_tx_$interface]="$(cat /sys/class/net/"$interface"/statistics/tx_bytes)"

        bytes_down=$(((${bytes[now_rx_$interface]} - ${bytes[past_rx_$interface]}) / INTERVAL))
        bytes_up=$(((${bytes[now_tx_$interface]} - ${bytes[past_tx_$interface]}) / INTERVAL))

        down=$((down + bytes_down))
        up=$((up + bytes_up))

        bytes[past_rx_$interface]=${bytes[now_rx_$interface]}
        bytes[past_tx_$interface]=${bytes[now_tx_$interface]}
    done
#  / Upload: $(print_bytes $up)
    echo "$(print_bytes $down)"

    sleep $INTERVAL
done
