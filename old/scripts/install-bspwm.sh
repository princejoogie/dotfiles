echo "[⌛] - Installing dependencies for bspwm and sxhkd..."
sudo apt-get install libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev -y
echo "[✅] - Dependencies for bspwm and sxhkd installed."

echo "[⌛] - Installing bspwm..."
git clone https://github.com/baskerville/bspwm.git "$INSTALL_DIR"/bspwm
cd "$INSTALL_DIR"/bspwm && make && sudo make install
echo "[✅] - Installed bspwm."

echo "[⌛] - Installing sxhkd..."
git clone https://github.com/baskerville/sxhkd.git "$INSTALL_DIR"/sxhkd
cd "$INSTALL_DIR"/sxhkd && make && sudo make install
echo "[✅] - Installed sxhkd."
