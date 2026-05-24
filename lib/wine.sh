#!/data/data/com.termux/files/usr/bin/bash
# lib/wine.sh — Gerenciamento de Wine/Hangover
# Sourced by script-termux.sh — NÃO executar diretamente.

install_wine() {
    if [ "${ARCH:-}" != "aarch64" ]; then
        warn "$(t wine_not_arm64)"
    fi

    if is_pkg_installed wine-stable; then
        run_cmd "remover wine-stable antigo" pkg remove -y wine-stable
    fi

    install_optional_packages hangover-wine hangover-wowbox64

    if [ -x "$PREFIX/opt/hangover-wine/bin/wine" ]; then
        ln -sf "$PREFIX/opt/hangover-wine/bin/wine" "$PREFIX/bin/wine"
        ok "$(t wine_shortcut_created)"
    else
        warn "$(t wine_not_complete)"
    fi

    INSTALL_WINE="y"
    save_config
}

remove_wine() {
    local confirm=""
    confirm="$(read_yes_no "  $(t wine_remove_confirm)" 'n')"
    if [ "$confirm" != "y" ]; then
        return 0
    fi

    info "$(t wine_remove)..."
    pkg remove -y hangover-wine hangover-wowbox64 >> "$LOG" 2>&1 || true
    rm -f "$PREFIX/bin/wine" 2>/dev/null || true
    pkg autoremove -y >> "$LOG" 2>&1 || true
    ok "$(t wine_removed)"

    INSTALL_WINE="n"
    save_config
}

get_wine_status() {
    if command_exists wine; then
        t status_installed
    else
        t status_not_installed
    fi
}

wine_menu() {
    while true; do
        echo ""
        _header "$(t wine_config_title)"
        printf "  |  Wine: %-30s|\n" "$(get_wine_status)"
        _line
        _item "1" "$(t wine_install)"
        _item "2" "$(t wine_remove)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1) install_wine ;;
            2) remove_wine ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}

# Usado na instalação completa
install_wine_if_requested() {
    if [ "$INSTALL_WINE" != "y" ]; then
        ok "$(t wine_skipped)"
        return 0
    fi

    install_wine
}
