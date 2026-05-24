#!/data/data/com.termux/files/usr/bin/bash
# lib/common.sh — Cores, logging, spinner, helpers compartilhados
# Sourced by script-termux.sh — NÃO executar diretamente.

# =========================
# Configuração global
# =========================
LOG="${HOME}/termux-linux-install.log"
START_LOG="${HOME}/termux-linux-start.log"
STATE_DIR="${HOME}/.termux-linux"
SPINNER_PID=""
TOTAL=11
CURRENT=0

DE_INPUT="1"
DE_NAME=""
DE_COMMAND=""
DE_CORE_PACKAGES=()
DE_EXTRA_PACKAGES=()
GPU_DRIVER="software"
GPU_ENABLED="false"
GPU_INFO=""
INSTALL_WINE="n"
ARCH=""
DEVICE_BRAND=""
DEVICE_MODEL=""

mkdir -p "$STATE_DIR"

# =========================
# Cores
# =========================
if [ -t 1 ]; then
    RED=$'\e[31m'
    GREEN=$'\e[32m'
    YELLOW=$'\e[33m'
    BLUE=$'\e[34m'
    CYAN=$'\e[36m'
    MAGENTA=$'\e[35m'
    BOLD=$'\e[1m'
    DIM=$'\e[2m'
    RESET=$'\e[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    MAGENTA=''
    BOLD=''
    DIM=''
    RESET=''
fi

# =========================
# Logging
# =========================
log_line() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

info() {
    printf "  %s->%s %s\n" "$BLUE" "$RESET" "$*"
    log_line "INFO: $*"
}

ok() {
    printf "  %s[OK]%s %s\n" "$GREEN" "$RESET" "$*"
    log_line "OK: $*"
}

warn() {
    printf "  %s[!]%s %s\n" "$YELLOW" "$RESET" "$*"
    log_line "AVISO: $*"
}

show_log_tail() {
    if [ -s "$LOG" ]; then
        echo ""
        echo "  $(t last_log_lines)"
        tail -n 25 "$LOG" | sed 's/^/    /'
    fi
}

die() {
    _stop_spinner
    echo ""
    printf "  %s%s:%s %s\n" "$RED" "$(t error_prefix)" "$RESET" "$*" >&2
    printf "  %s\n" "$(t log_complete "$LOG")" >&2
    show_log_tail >&2
    exit 1
}

on_error() {
    local line="$1"
    local cmd="$2"
    _stop_spinner
    echo ""
    printf "  %s%s%s\n" "$RED" "$(t unexpected_error_line "$line" "$cmd")" "$RESET" >&2
    printf "  %s\n" "$(t log_complete "$LOG")" >&2
    show_log_tail >&2
    exit 1
}

# =========================
# Spinner e Progresso
# =========================
_stop_spinner() {
    if [ -n "${SPINNER_PID:-}" ]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        printf "\r\033[K"
        SPINNER_PID=""
    fi
    return 0
}

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
    printf "  %s[%02d/%02d]%s %s\n" "$BOLD" "$CURRENT" "$TOTAL" "$RESET" "$msg"
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
    ok "$(printf "$(t step_completed)" "$CURRENT" "$TOTAL")"
}

# =========================
# Comandos e instalação
# =========================
run_cmd() {
    local desc="$1"
    shift
    log_line "CMD: $*"
    if ! "$@" >> "$LOG" 2>&1; then
        die "$(printf "$(t failed_at)" "$desc")"
    fi
}

install_with_retry() {
    local pkg="$1"
    local max_attempts="${2:-3}"
    local attempt=1

    while [ "$attempt" -le "$max_attempts" ]; do
        if pkg install -y "$pkg" >> "$LOG" 2>&1; then
            ok "$(printf "$(t installed)" "$pkg")"
            return 0
        fi
        warn "$(printf "$(t attempt_failed)" "$attempt" "$max_attempts" "$pkg" "$attempt")"
        sleep "$attempt"
        attempt=$((attempt + 1))
    done

    return 1
}

install_required() {
    local label="$1"
    shift
    local pkg_name=""
    for pkg_name in "$@"; do
        info "$(printf "$(t installing)" "$pkg_name")"
        run_cmd "instalar $label: $pkg_name" pkg install -y "$pkg_name"
    done
}

install_optional_packages() {
    local pkg_name=""
    for pkg_name in "$@"; do
        info "$(printf "$(t trying_install_optional)" "$pkg_name")"
        if pkg install -y "$pkg_name" >> "$LOG" 2>&1; then
            ok "$(printf "$(t installed)" "$pkg_name")"
        else
            warn "$(printf "$(t optional_pkg_failed)" "$pkg_name")"
        fi
    done
}

install_any_required() {
    local label="$1"
    shift
    local pkg_name=""

    for pkg_name in "$@"; do
        info "$(printf "$(t trying_install)" "$label" "$pkg_name")"
        if pkg install -y "$pkg_name" >> "$LOG" 2>&1; then
            ok "$(printf "$(t installed)" "$pkg_name")"
            return 0
        fi
    done

    die "$(printf "$(t no_option_available)" "$label" "$*")"
}

# =========================
# Helpers
# =========================
command_exists() {
    command -v "$1" >/dev/null 2>&1 || return 1
}

is_pkg_installed() {
    dpkg -s "$1" > /dev/null 2>&1 || return 1
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
        echo "  $(t invalid_option)"
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
            s|sim|y|yes) printf 'y\n'; return 0 ;;
            n|nao|não|no) printf 'n\n'; return 0 ;;
            *) echo "  $(t answer_yes_no)" ;;
        esac
    done
}

pause_prompt() {
    echo ""
    read -r -p "  $(t press_enter) " || true
}

# =========================
# Config
# =========================
save_config() {
    cat > "${STATE_DIR}/config.env" <<EOF_CONFIG
DE_NAME="$DE_NAME"
DE_COMMAND="$DE_COMMAND"
GPU_ENABLED="$GPU_ENABLED"
GPU_DRIVER="$GPU_DRIVER"
INSTALL_WINE="$INSTALL_WINE"
CURRENT_LANG="${CURRENT_LANG:-pt}"
EOF_CONFIG
}

load_config() {
    local config="${STATE_DIR}/config.env"
    if [ -f "$config" ]; then
        # shellcheck disable=SC1090
        source "$config"
        return 0
    fi
    return 1
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
