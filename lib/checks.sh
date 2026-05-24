#!/data/data/com.termux/files/usr/bin/bash
# lib/checks.sh — Verificações de sistema
# Sourced by script-termux.sh — NÃO executar diretamente.

require_termux() {
    if [ "${PREFIX:-}" != "/data/data/com.termux/files/usr" ]; then
        die "$(t must_run_in_termux)"
    fi

    command_exists pkg || die "$(t pkg_not_found)"
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
            die "$(t apt_stuck)"
        fi
        warn "$(t waiting_apt)"
        sleep 3
        waited=$((waited + 3))
    done
}
