# Set default applications for common file types

update-desktop-database ~/.local/share/applications 2>/dev/null || true

# Open directories in file manager (dolphin)
xdg-mime default org.kde.dolphin.desktop inode/directory 2>/dev/null || true

# Open images with qview
for mime in image/png image/jpeg image/gif image/webp image/bmp image/tiff; do
  xdg-mime default com.interversehq.qView.desktop "$mime" 2>/dev/null || true
done

# Open PDFs with zathura
xdg-mime default org.pwmt.zathura.desktop application/pdf 2>/dev/null || true

# Open video files with mpv
for mime in video/mp4 video/x-msvideo video/x-matroska video/x-flv video/x-ms-wmv \
  video/mpeg video/ogg video/webm video/quicktime video/3gpp video/3gpp2 \
  video/x-ms-asf video/x-ogm+ogg video/x-theora+ogg application/ogg; do
  xdg-mime default mpv.desktop "$mime" 2>/dev/null || true
done

# Open text files with nvim
for mime in text/plain text/english text/x-makefile text/x-c++hdr text/x-c++src \
  text/x-chdr text/x-csrc text/x-java text/x-moc text/x-pascal text/x-tcl \
  text/x-tex application/x-shellscript text/x-c text/x-c++ application/xml text/xml; do
  xdg-mime default nvim.desktop "$mime" 2>/dev/null || true
done

echo "Default mimetypes: OK"
