#!/data/data/com.termux/files/usr/bin/bash
# lib/scripts.sh — Geração de scripts auxiliares (start, stop, info)
# Sourced by script-termux.sh — NÃO executar diretamente.

write_start_script() {
    cat > "${HOME}/start-linux.sh" <<EOF_START
#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

LOG="${START_LOG}"
: > "\$LOG"

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export TMPDIR="\${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "\$TMPDIR"

export XDG_RUNTIME_DIR="\$TMPDIR"
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export QT_X11_NO_MITSHM=1
export NO_AT_BRIDGE=1
export PULSE_SERVER=127.0.0.1
EOF_START

    if [ "$GPU_ENABLED" = "true" ]; then
        cat >> "${HOME}/start-linux.sh" <<'EOF_GPU'
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export MESA_NO_ERROR=1
EOF_GPU
    else
        cat >> "${HOME}/start-linux.sh" <<'EOF_GPU'
export LIBGL_ALWAYS_SOFTWARE=1
EOF_GPU
    fi

    cat >> "${HOME}/start-linux.sh" <<EOF_START2

stop_old_sessions() {
    pkill -f "${DE_COMMAND}" 2>/dev/null || true
    pkill -f "termux-x11.*:0" 2>/dev/null || true
    pulseaudio --kill >/dev/null 2>&1 || true
}

start_audio() {
    pulseaudio --start --exit-idle-time=-1 >> "\$LOG" 2>&1 || true
    pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 >> "\$LOG" 2>&1 || true
}

start_x11() {
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >> "\$LOG" 2>&1 || true
    termux-x11 :0 >> "\$LOG" 2>&1 &
    sleep 3
}

echo "Iniciando Termux Linux/X11..."
stop_old_sessions
sleep 1
start_audio
start_x11

start_desktop() {
    cd "\$HOME"

    if command -v dbus-launch >/dev/null 2>&1; then
        exec dbus-launch --exit-with-session ${DE_COMMAND}
    fi

    echo "Aviso: dbus-launch não encontrado. Iniciando ${DE_NAME} sem dbus-launch." >> "\$LOG"
    exec ${DE_COMMAND}
}

start_desktop
EOF_START2

    chmod +x "${HOME}/start-linux.sh"
}

write_stop_script() {
    cat > "${HOME}/stop-linux.sh" <<'EOF_STOP'
#!/data/data/com.termux/files/usr/bin/bash

pkill -f "startxfce4|startlxqt|mate-session|startplasma-x11|xfce4-session|lxqt-session" 2>/dev/null || true
pkill -f "termux-x11.*:0" 2>/dev/null || true
pulseaudio --kill >/dev/null 2>&1 || true

echo "Desktop finalizado."
EOF_STOP

    chmod +x "${HOME}/stop-linux.sh"
}

write_info_script() {
    cat > "${HOME}/linux-info.sh" <<'EOF_INFO'
#!/data/data/com.termux/files/usr/bin/bash

echo "===== Termux Linux/X11 - Diagnóstico ====="
echo "Data: $(date)"
echo "Arquitetura: $(uname -m)"
echo "PREFIX: ${PREFIX:-desconhecido}"
echo "DISPLAY: ${DISPLAY:-não definido}"
echo ""
echo "Comandos encontrados:"
for cmd in termux-x11 dbus-launch startxfce4 startlxqt mate-session startplasma-x11 pulseaudio; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [OK] $cmd -> $(command -v "$cmd")"
    else
        echo "  - $cmd não encontrado"
    fi
done

echo ""
echo "Últimas linhas do log de instalação:"
tail -n 30 "$HOME/termux-linux-install.log" 2>/dev/null || true

echo ""
echo "Últimas linhas do log de inicialização:"
tail -n 30 "$HOME/termux-linux-start.log" 2>/dev/null || true
EOF_INFO

    chmod +x "${HOME}/linux-info.sh"
}

create_desktop_shortcuts() {
    mkdir -p "${HOME}/Desktop"

    if command_exists firefox; then
        cat > "${HOME}/Desktop/Firefox.desktop" <<'EOF_FIREFOX'
[Desktop Entry]
Name=Firefox
Exec=firefox
Type=Application
Categories=Network;WebBrowser;
Terminal=false
EOF_FIREFOX
    fi

    if command_exists code-oss; then
        cat > "${HOME}/Desktop/CodeOSS.desktop" <<'EOF_CODE'
[Desktop Entry]
Name=Code OSS
Exec=code-oss --no-sandbox
Type=Application
Categories=Development;
Terminal=false
EOF_CODE
    fi

    chmod +x "${HOME}/Desktop"/*.desktop 2>/dev/null || true
}

write_all_scripts() {
    write_start_script
    write_stop_script
    write_info_script
    create_desktop_shortcuts
    ok "$(t scripts_created)"
}
