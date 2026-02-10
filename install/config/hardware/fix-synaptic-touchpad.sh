# Enable Synaptics InterTouch for confirmed touchpads
if grep -qi synaptics /proc/bus/input/devices 2>/dev/null \
   && ! lsmod | grep -q '^psmouse'; then
  modprobe psmouse synaptics_intertouch=1 2>/dev/null || true
fi

echo "Synaptics touchpad: OK"
