#!/data/data/com.termux/files/usr/bin/bash
# Instalador de ambiente gráfico para Termux + Termux-X11

set -Eeuo pipefail
IFS=$'\n\t'

# =========================
# Configuração
# =========================
LOG="${HOME}/termux-linux-install.log"
START_LOG="${HOME}/termux-linux-start.log"
STATE_DIR="${HOME}/.termux-linux"
SPINNER_PID=""
TOTAL=11
CURRENT=0

DE_INPUT="1"
DE_NAME="XFCE4"
DE_COMMAND="startxfce4"
GPU_DRIVER="software"
GPU_ENABLED="false"
INSTALL_WINE="n"

mkdir -p "$STATE_DIR"
: > "$LOG"

# =========================
# Cores e mensagens
# =========================
if [ -t 1 ]; then
    RED='\033[31m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    BLUE='\033[34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    RESET=''
fi

log_line() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

info() {
    printf "  ${BLUE}->${RESET} %s\n" "$*"
    log_line "INFO: $*"
}

ok() {
    printf "  ${GREEN}✓${RESET} %s\n" "$*"
    log_line "OK: $*"
}

warn() {
    printf "  ${YELLOW}!${RESET} %s\n" "$*"
    log_line "AVISO: $*"
}

_stop_spinner() {
    if [ -n "${SPINNER_PID:-}" ]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        printf "\r\033[K"
        SPINNER_PID=""
    fi
}

show_log_tail() {
    if [ -s "$LOG" ]; then
        echo ""
        echo "  Últimas linhas do log:"
        tail -n 25 "$LOG" | sed 's/^/    /'
    fi
}

die() {
    _stop_spinner
    echo ""
    printf "  ${RED}ERRO:${RESET} %s\n" "$*" >&2
    echo "  Log completo: $LOG" >&2
    show_log_tail >&2
    exit 1
}

on_error() {
    local line="$1"
    local cmd="$2"
    _stop_spinner
    echo ""
    printf "  ${RED}ERRO inesperado na linha %s:${RESET} %s\n" "$line" "$cmd" >&2
    echo "  Log completo: $LOG" >&2
    show_log_tail >&2
    exit 1
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR
trap '_stop_spinner' EXIT

start_step() {
    _stop_spinner
    CURRENT=$((CURRENT + 1))
    local msg="$1"
    local pct=$((CURRENT * 100 / TOTAL))
    local filled=$((pct * 24 / 100))
    local bar_fill=""
    local bar=""

    if [ "$filled" -gt 0 ]; then
        bar_fill=$(printf '%*s' "$filled" '' | tr ' ' '=')
    fi

    if [ "$filled" -lt 24 ]; then
        bar=$(printf "%-24s" "${bar_fill}>")
    else
        bar="$bar_fill"
    fi

    echo ""
    printf "  ${BOLD}[%02d/%02d]${RESET} %s\n" "$CURRENT" "$TOTAL" "$msg"
    log_line "PASSO $CURRENT/$TOTAL: $msg"

    (
        i=0
        chars='|/-\'
        while true; do
            printf "\r  [%-24s] %3d%% %s" "$bar" "$pct" "${chars:$((i % 4)):1}"
            i=$((i + 1))
            sleep 0.2
        done
    ) &
    SPINNER_PID=$!
}

end_step() {
    _stop_spinner
    ok "Passo $CURRENT/$TOTAL concluído"
}

run_cmd() {
    local desc="$1"
    shift
    log_line "CMD: $*"
    if ! "$@" >> "$LOG" 2>&1; then
        die "Falha em: $desc"
    fi
}

install_required() {
    local label="$1"
    shift
    info "Instalando: $*"
    run_cmd "instalar $label" pkg install -y "$@"
}

install_optional_packages() {
    local pkg_name=""
    for pkg_name in "$@"; do
        info "Tentando instalar pacote opcional: $pkg_name"
        if pkg install -y "$pkg_name" >> "$LOG" 2>&1; then
            ok "Instalado: $pkg_name"
        else
            warn "Pacote opcional indisponível ou falhou: $pkg_name"
        fi
    done
}

install_any_required() {
    local label="$1"
    shift
    local pkg_name=""

    for pkg_name in "$@"; do
        info "Tentando instalar $label: $pkg_name"
        if pkg install -y "$pkg_name" >> "$LOG" 2>&1; then
            ok "Instalado: $pkg_name"
            return 0
        fi
    done

    die "Nenhuma opção disponível para instalar: $label ($*)"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_termux() {
    if [ "${PREFIX:-}" != "/data/data/com.termux/files/usr" ]; then
        die "Este script deve ser executado dentro do Termux normal, não em Linux/PC/proot."
    fi

    command_exists pkg || die "Comando 'pkg' não encontrado. Atualize/reinstale o Termux."
}

check_internet() {
    if command_exists curl; then
        curl -fsI --connect-timeout 12 https://packages.termux.dev >/dev/null 2>>"$LOG" && return 0
        curl -fsI --connect-timeout 12 https://google.com >/dev/null 2>>"$LOG" && return 0
    fi

    ping -c 1 -W 8 packages.termux.dev >> "$LOG" 2>&1 && return 0
    ping -c 1 -W 8 google.com >> "$LOG" 2>&1 && return 0

    return 1
}

wait_package_manager() {
    local waited=0
    while pgrep -x apt >/dev/null 2>&1 || \
          pgrep -x apt-get >/dev/null 2>&1 || \
          pgrep -x dpkg >/dev/null 2>&1; do
        if [ "$waited" -ge 90 ]; then
            die "Outro processo do apt/dpkg está travado há muito tempo. Feche outros Termux e tente novamente."
        fi
        warn "Aguardando outro processo apt/dpkg terminar..."
        sleep 3
        waited=$((waited + 3))
    done
}

read_choice() {
    local prompt="$1"
    local default="$2"
    local pattern="$3"
    local value=""

    while true; do
        read -r -p "$prompt" value || value="$default"
        value="${value:-$default}"
        if [[ "$value" =~ $pattern ]]; then
            printf '%s\n' "$value"
            return 0
        fi
        echo "  Opção inválida. Tente novamente."
    done
}

read_yes_no() {
    local prompt="$1"
    local default="$2"
    local value=""

    while true; do
        read -r -p "$prompt" value || value="$default"
        value="${value:-$default}"
        value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
        case "$value" in
            s|sim|y|yes) printf 's\n'; return 0 ;;
            n|nao|não|no) printf 'n\n'; return 0 ;;
            *) echo "  Responda com s ou n." ;;
        esac
    done
}

banner() {
    clear 2>/dev/null || true
    echo ""
    cat << 'ART'
|    | |\ | |  | \_/
|___ | | \| \__/ / \

           __   __   __     __
 /\  |\ | |  \ |__) /  \ | |  \
/~~\ | \| |__/ |  \ \__/ | |__/
ART
    echo ""
    echo "  ======================================"
    echo "      Configurando Termux Linux/X11"
    echo "  ======================================"
    echo ""
}

collect_device_info() {
    ARCH="$(uname -m)"
    DEVICE_BRAND="$(getprop ro.product.brand 2>/dev/null || echo 'Unknown')"
    DEVICE_MODEL="$(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
    GPU_INFO="$(
        {
            getprop ro.hardware.egl
            getprop ro.hardware.vulkan
            getprop ro.board.platform
            getprop ro.hardware
        } 2>/dev/null | tr '[:upper:]' '[:lower:]'
    )"

    info "Arquitetura: $ARCH"
    info "Dispositivo: $DEVICE_BRAND $DEVICE_MODEL"

    if [ "$ARCH" != "aarch64" ]; then
        warn "Wine/Hangover e aceleração gráfica costumam funcionar melhor em ARM64/aarch64."
    fi
}

choose_gpu() {
    echo ""
    echo "  -- Configuração de GPU --"
    echo "   1) Automático (recomendado)"
    echo "   2) Forçar aceleração GPU Adreno/Freedreno"
    echo "   3) Desativar aceleração GPU/usar software"
    echo ""

    local gpu_option=""
    gpu_option="$(read_choice '  Opção [1-3, padrão=1]: ' '1' '^[1-3]$')"

    case "$gpu_option" in
        1)
            if printf '%s' "$GPU_INFO" | grep -Eq 'adreno|qcom|qualcomm|msm'; then
                GPU_DRIVER="freedreno"
                GPU_ENABLED="true"
                ok "GPU Qualcomm/Adreno detectada. Aceleração será ativada."
            else
                GPU_DRIVER="software"
                GPU_ENABLED="false"
                warn "GPU Adreno não detectada. Usarei modo compatível sem aceleração forçada."
            fi
        ;;
        2)
            GPU_DRIVER="freedreno"
            GPU_ENABLED="true"
            warn "Aceleração GPU foi forçada. Se a tela ficar preta/travar, rode novamente e escolha a opção 3."
        ;;
        3)
            GPU_DRIVER="software"
            GPU_ENABLED="false"
            ok "Aceleração GPU desativada."
        ;;
    esac
}

choose_desktop() {
    echo ""
    echo "  -- Escolha o Desktop --"
    echo "   1) XFCE4      (recomendado/mais estável)"
    echo "   2) LXQt       (leve)"
    echo "   3) MATE       (médio)"
    echo "   4) KDE Plasma (pesado/experimental)"
    echo ""

    DE_INPUT="$(read_choice '  Opção [1-4, padrão=1]: ' '1' '^[1-4]$')"

    case "$DE_INPUT" in
        1)
            DE_NAME="XFCE4"
            DE_COMMAND="startxfce4"
            DE_CORE_PACKAGES=(xfce4 dbus pulseaudio)
            DE_EXTRA_PACKAGES=(xfce4-terminal thunar mousepad pavucontrol shared-mime-info fontconfig)
        ;;
        2)
            DE_NAME="LXQt"
            DE_COMMAND="startlxqt"
            DE_CORE_PACKAGES=(lxqt-session openbox dbus pulseaudio)
            DE_EXTRA_PACKAGES=(lxqt-panel pcmanfm-qt qterminal featherpad gtk3 pavucontrol shared-mime-info fontconfig)
        ;;
        3)
            DE_NAME="MATE"
            DE_COMMAND="mate-session"
            DE_CORE_PACKAGES=(mate-session-manager marco dbus pulseaudio)
            DE_EXTRA_PACKAGES=(mate-panel mate-terminal fontconfig shared-mime-info)
        ;;
        4)
            DE_NAME="KDE Plasma"
            DE_COMMAND="startplasma-x11"
            DE_CORE_PACKAGES=(plasma-desktop dbus pulseaudio)
            DE_EXTRA_PACKAGES=(konsole fontconfig shared-mime-info)
        ;;
    esac

    ok "Desktop escolhido: $DE_NAME"
}

prepare_environment() {
    export DEBIAN_FRONTEND=noninteractive
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    export TMPDIR="${TMPDIR:-$PREFIX/tmp}"

    mkdir -p "$TMPDIR"
    mkdir -p "$PREFIX/etc/apt/apt.conf.d"

    cat > "$PREFIX/etc/apt/apt.conf.d/99termux-noninteractive" <<'APTCONF'
DPkg::Options {
  "--force-confdef";
  "--force-confold";
};
APTCONF
}

install_desktop() {
    # No Termux atual, o pacote dbus-x11 pode não existir. Por isso ele não é usado
    # como dependência obrigatória. O script usa dbus-launch apenas se o comando existir.
    local pkg_name=""

    for pkg_name in "${DE_CORE_PACKAGES[@]}"; do
        install_required "pacote obrigatório do $DE_NAME: $pkg_name" "$pkg_name"
    done

    install_optional_packages "${DE_EXTRA_PACKAGES[@]}"

    if ! command_exists "$DE_COMMAND"; then
        die "O comando '$DE_COMMAND' não foi encontrado após instalar $DE_NAME. Veja o log e tente outro desktop."
    fi
}

install_gpu_drivers() {
    if [ "$GPU_ENABLED" = "true" ]; then
        info "Instalando base gráfica Vulkan/Zink"
        if pkg install -y mesa-zink vulkan-loader-android >> "$LOG" 2>&1; then
            ok "Base gráfica instalada"
        else
            warn "Drivers mesa-zink/vulkan-loader-android falharam. Vou continuar em modo software."
            GPU_ENABLED="false"
            GPU_DRIVER="software"
            return 0
        fi

        if [ "$GPU_DRIVER" = "freedreno" ]; then
            install_optional_packages mesa-vulkan-icd-freedreno vulkan-tools
        fi
    else
        ok "Modo software selecionado. Drivers GPU extras não serão forçados."
    fi
}

install_wine_if_requested() {
    if [ "$INSTALL_WINE" != "s" ]; then
        ok "Wine/Hangover ignorado."
        return 0
    fi

    if [ "${ARCH:-}" != "aarch64" ]; then
        warn "Seu aparelho não parece ser ARM64/aarch64. Wine/Hangover pode não funcionar bem."
    fi

    if dpkg -s wine-stable >/dev/null 2>&1; then
        run_cmd "remover wine-stable antigo" pkg remove -y wine-stable
    fi

    install_optional_packages hangover-wine hangover-wowbox64

    if [ -x "$PREFIX/opt/hangover-wine/bin/wine" ]; then
        ln -sf "$PREFIX/opt/hangover-wine/bin/wine" "$PREFIX/bin/wine"
        ok "Atalho 'wine' criado."
    else
        warn "Hangover Wine não parece ter sido instalado completamente."
    fi
}

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
        echo "  ✓ $cmd -> $(command -v "$cmd")"
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

save_config() {
    cat > "${STATE_DIR}/config.env" <<EOF_CONFIG
DE_NAME="$DE_NAME"
DE_COMMAND="$DE_COMMAND"
GPU_ENABLED="$GPU_ENABLED"
GPU_DRIVER="$GPU_DRIVER"
INSTALL_WINE="$INSTALL_WINE"
EOF_CONFIG
}

# =========================
# Execução principal
# =========================
main() {
    banner
    require_termux

    echo "  Log da instalação: $LOG"
    echo ""

    info "Verificando internet..."
    check_internet || die "Sem conexão com internet ou DNS indisponível."

    collect_device_info
    choose_gpu
    choose_desktop

    echo ""
    INSTALL_WINE="$(read_yes_no '  Instalar Wine/Hangover? [s/N]: ' 'n')"

    start_step "Preparando ambiente"
    prepare_environment
    wait_package_manager
    run_cmd "corrigir dpkg pendente" dpkg --configure -a
    end_step

    start_step "Atualizando sistema"
    run_cmd "pkg update" pkg update -y
    run_cmd "pkg upgrade" pkg upgrade -y
    end_step

    start_step "Adicionando repositórios"
    install_required "repositórios" x11-repo tur-repo
    run_cmd "atualizar lista após repositórios" pkg update -y
    end_step

    start_step "Instalando servidor gráfico"
    install_any_required "Termux-X11" termux-x11 termux-x11-nightly
    install_required "ferramentas X11" xorg-xrandr xorg-xhost xorg-xsetroot
    end_step

    start_step "Instalando $DE_NAME"
    install_desktop
    end_step

    start_step "Configurando GPU"
    install_gpu_drivers
    end_step

    start_step "Instalando áudio"
    install_required "áudio" pulseaudio
    end_step

    start_step "Instalando apps e utilitários"
    install_required "ferramentas básicas" git wget curl python nano tar unzip zip openssl
    install_optional_packages neofetch vlc firefox code-oss wol
    end_step

    start_step "Configurando Wine/Hangover"
    install_wine_if_requested
    end_step

    start_step "Criando scripts de inicialização"
    write_start_script
    write_stop_script
    write_info_script
    save_config
    end_step

    start_step "Criando atalhos"
    create_desktop_shortcuts
    end_step

    _stop_spinner
    echo ""
    if command_exists neofetch; then
        neofetch || true
    fi

    echo ""
    echo "  ======================================"
    printf "      ${GREEN}INSTALAÇÃO CONCLUÍDA${RESET}\n"
    echo "  ======================================"
    echo ""
    echo "  Desktop : $DE_NAME"
    echo "  GPU     : $GPU_DRIVER / enabled=$GPU_ENABLED"
    echo ""
    echo "  Iniciar : ~/start-linux.sh"
    echo "  Parar   : ~/stop-linux.sh"
    echo "  Info    : ~/linux-info.sh"
    echo "  Log     : $LOG"
    echo ""
    echo "  Depois de iniciar, abra o app Termux-X11 para ver a interface."
    echo ""
}

main "$@"
