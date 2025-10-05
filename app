#!/bin/bash
APP_NAME="System Info GUI"
BIN_NAME="sysinfo_gui"
VERSION="1.1.2"
INSTALL_PATH="/usr/local/bin/$BIN_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$BIN_NAME.desktop"
ICON_PATH="/usr/share/icons/gnome/256x256/apps/computer.png"
GITHUB_REPO="" 

if ! command -v zenity &> /dev/null; then
    sudo apt update
    sudo apt install -y zenity lsb-release curl
fi

sudo bash -c "cat > $INSTALL_PATH" <<EOF
#!/bin/bash
if [ "\$EUID" -ne 0 ]; then
    zenity --question --title="$APP_NAME" --text="Для полной информации нужны права root. Запустить с sudo?"
    if [ \$? -eq 0 ]; then
        exec sudo \$0 "\$@"
    else
        zenity --error --text="Приложение требует права root. Выход."
        exit 1
    fi
fi

UPDATE_INFO=""
if command -v curl &> /dev/null && [ ! -z "$GITHUB_REPO" ]; then
    RESPONSE=\$(curl -s "$GITHUB_REPO")
    if [ ! -z "\$RESPONSE" ]; then
        zenity --info --title="Обновление найдено" --text="\$RESPONSE"
    fi
fi

get_sys_info() {
    OS_NAME=\$(lsb_release -d 2>/dev/null | cut -f2-)
    [ -z "\$OS_NAME" ] && OS_NAME=\$(uname -s)
    KERNEL=\$(uname -r)
    HOSTNAME=\$(hostname)
    IP_ADDR=\$(hostname -I | awk '{print \$1}')
    CPU=\$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    CORES=\$(lscpu | grep "^CPU(s):" | awk '{print \$2}')
    THREADS=\$(lscpu | grep "^Thread(s) per core:" | awk '{print \$4}')
    CPU_FREQ=\$(lscpu | grep "CPU MHz" | awk '{print \$3}')
    RAM_TOTAL=\$(free -m | awk '/Mem:/ {print \$2}')
    RAM_USED=\$(free -m | awk '/Mem:/ {print \$3}')
    DISK_TOTAL=\$(df -h / | awk 'NR==2 {print \$2}')
    DISK_USED=\$(df -h / | awk 'NR==2 {print \$3}')
    UPTIME=\$(uptime -p)
    INFO="OS: \$OS_NAME
Kernel: \$KERNEL
Hostname: \$HOSTNAME
IP: \$IP_ADDR

CPU: \$CPU
Cores: \$CORES
Threads: \$THREADS
CPU MHz: \$CPU_FREQ

RAM: \${RAM_USED}MB / \${RAM_TOTAL}MB
Disk: \${DISK_USED} / \${DISK_TOTAL}
Uptime: \$UPTIME

Distro: \$OS_NAME
"
    echo "\$INFO"
}

while true; do
    INFO_TEXT=\$(get_sys_info)
    zenity --text-info --title="$APP_NAME v$VERSION" \
        --width=600 --height=500 \
        --ok-label="Refresh" \
        --no-wrap \
        <<< "\$INFO_TEXT"
    if [ \$? -ne 0 ]; then
        exit 0
    fi
done
EOF

sudo chmod +x "$INSTALL_PATH"

mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$APP_NAME
Comment=System information GUI
Exec=$BIN_NAME
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;
EOL

echo "Установка завершена. Запуск приложения: $BIN_NAME"
