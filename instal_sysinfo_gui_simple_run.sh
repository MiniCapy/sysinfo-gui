#!/bin/bash
APP_NAME="System Info GUI"
BIN_NAME="sysinfo_gui"
VERSION="1.1.2"
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_PATH="$HOME/.local/share/icons/sysinfo_gui.png"
GITHUB_URL="https://raw.githubusercontent.com/MiniCapy/sysinfo-gui/refs/heads/main/app"
ICON_URL="https://raw.githubusercontent.com/MiniCapy/sysinfo-gui/refs/heads/main/icon.png"

mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$(dirname "$ICON_PATH")"

curl -sL "$GITHUB_URL" -o "$INSTALL_DIR/$BIN_NAME"
chmod +x "$INSTALL_DIR/$BIN_NAME"

curl -sL "$ICON_URL" -o "$ICON_PATH"

cat > "$DESKTOP_DIR/$BIN_NAME.desktop" <<EOL
[Desktop Entry]
Name=$APP_NAME
Comment=System information GUI
Exec=$INSTALL_DIR/$BIN_NAME
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;
EOL

echo "Установка завершена!"
echo "Приложение '$APP_NAME' доступно через меню."
echo "Версия: $VERSION"
echo "Исполняемый файл: $INSTALL_DIR/$BIN_NAME"

"$INSTALL_DIR/$BIN_NAME"
