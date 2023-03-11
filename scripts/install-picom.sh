echo "[⌛] - Installing dependencies for picom..."
sudo apt install libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl-dev libegl-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson
echo "[✅] - Dependencies for picom installed."


echo "[⌛] - Installing picom..."
git clone https://github.com/yshui/picom "$INSTALL_DIR"/picom
cd "$INSTALL_DIR"/picom || exit
git submodule update --init --recursive
meson setup --buildtype=release . build
ninja -C build
sudo ninja -C build install
echo "[✅] - Installed picom."
