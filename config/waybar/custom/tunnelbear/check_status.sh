#!/bin/bash

# Check if TunnelBear Japan connection is active
if nmcli connection show --active | grep -q "TunnelBear Japan"; then
    tooltip="TunnelBear VPN\rStatus: Connected\rLocation: Japan"
    echo "{\"text\": \"ON\", \"tooltip\": \"$tooltip\"}"
else
    echo "{\"text\": \"OFF\", \"tooltip\": \"TunnelBear VPN is not running\"}"
fi