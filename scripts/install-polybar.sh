echo "[⌛] - Installing dependencies for polybar..."
sudo apt install build-essential git cmake cmake-data pkg-config python3-sphinx python3-packaging libuv1-dev libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev -y
echo "[✅] - Dependencies for polybar installed."


echo "[⌛] - Installing polybar..."
git clone --recursive https://github.com/polybar/polybar "$INSTALL_DIR"/polybar
cd "$INSTALL_DIR"/polybar || exit
mkdir build && cd build || exit
cmake .. && make -j"$(nproc)"
sudo make install
echo "[✅] - Installed polybar."
