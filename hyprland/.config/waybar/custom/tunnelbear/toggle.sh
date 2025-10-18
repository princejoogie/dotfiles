#!/bin/bash

# Check if TunnelBear Japan connection is active
if nmcli connection show --active | grep -q "TunnelBear Japan"; then
    nmcli connection down "TunnelBear Japan"
else
    nmcli connection up "TunnelBear Japan"
fi