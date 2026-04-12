# Auto-switch power profiles on AC/battery via udev rules
# Only applies if a battery is present and powerprofilesctl is available

if command -v powerprofilesctl &>/dev/null && [ -d /sys/class/power_supply/BAT0 ]; then
  mapfile -t profiles < <(kojarchy-powerprofiles-list)

  if [[ ${#profiles[@]} -gt 1 ]]; then
    # Default AC profile: performance if 3 profiles, balanced if 2
    ac_profile="${profiles[2]:-${profiles[1]}}"
    # Default Battery profile: balanced
    battery_profile="${profiles[1]}"

    cat <<EOF | sudo tee "/etc/udev/rules.d/99-power-profile.rules"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set $battery_profile"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set $ac_profile"
EOF

    sudo udevadm control --reload
    sudo udevadm trigger --subsystem-match=power_supply
    echo "Power profile auto-switch: OK"
  else
    echo "Power profiles: only one profile available, skipping"
  fi
else
  echo "Power profiles: no battery or powerprofilesctl not found, skipping"
fi
