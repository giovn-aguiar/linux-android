#!/data/data/com.termux/files/usr/bin/bash
# lib/themes.sh — Temas e personalização
# Sourced by script-termux.sh — NÃO executar diretamente.

install_dark_theme() {
    echo ""
    echo "  -- $(t themes_dark) --"
    echo "   1) $(t themes_arc_dark)"
    echo "   2) $(t themes_gruvbox)"
    echo ""

    local choice=""
    choice="$(read_choice "  $(t themes_select_theme)" '1' '^[1-2]$')"

    case "$choice" in
        1)
            install_optional_packages arc-theme
            # Aplicar tema no XFCE4 se disponível
            if command_exists xfconf-query; then
                xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark" 2>/dev/null || true
                xfconf-query -c xfwm4 -p /general/theme -s "Arc-Dark" 2>/dev/null || true
            fi
            ok "$(t themes_installed "Arc Dark")"
        ;;
        2)
            install_optional_packages gruvbox-dark-gtk
            if command_exists xfconf-query; then
                xfconf-query -c xsettings -p /Net/ThemeName -s "Gruvbox-Dark" 2>/dev/null || true
            fi
            ok "$(t themes_installed "Gruvbox Dark")"
        ;;
    esac
}

install_icon_pack() {
    echo ""
    echo "  -- $(t themes_icons) --"
    echo "   1) $(t themes_papirus)"
    echo "   2) $(t themes_adwaita)"
    echo ""

    local choice=""
    choice="$(read_choice "  $(t themes_select_icons)" '1' '^[1-2]$')"

    case "$choice" in
        1)
            install_optional_packages papirus-icon-theme
            if command_exists xfconf-query; then
                xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" 2>/dev/null || true
            fi
            ok "$(t themes_icons_installed "Papirus")"
        ;;
        2)
            install_optional_packages adwaita-icon-theme
            if command_exists xfconf-query; then
                xfconf-query -c xsettings -p /Net/IconThemeName -s "Adwaita" 2>/dev/null || true
            fi
            ok "$(t themes_icons_installed "Adwaita")"
        ;;
    esac
}

install_fonts() {
    info "$(t themes_fonts)..."
    install_optional_packages \
        fontconfig \
        font-dejavu \
        font-noto \
        font-noto-emoji

    # Rebuild font cache
    if command_exists fc-cache; then
        fc-cache -fv >> "$LOG" 2>&1 || true
    fi

    ok "$(t themes_fonts_installed)"
}

set_wallpaper() {
    local wallpaper_path=""
    read -r -p "  $(t themes_wallpaper_path)" wallpaper_path || return

    if [ -z "$wallpaper_path" ]; then
        return
    fi

    if [ ! -f "$wallpaper_path" ]; then
        warn "$(t themes_wallpaper_not_found)"
        return 1
    fi

    # Copia para pasta local
    mkdir -p "${HOME}/.local/share/wallpapers"
    cp "$wallpaper_path" "${HOME}/.local/share/wallpapers/current-wallpaper" 2>/dev/null || true

    # Tenta aplicar no XFCE4
    if command_exists xfconf-query; then
        local monitor=""
        for monitor in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image$"); do
            xfconf-query -c xfce4-desktop -p "$monitor" -s "$wallpaper_path" 2>/dev/null || true
        done
    fi

    ok "$(t themes_wallpaper_set)"
}

themes_menu() {
    while true; do
        echo ""
        _header "$(t themes_title)"
        _item "1" "$(t themes_dark)"
        _item "2" "$(t themes_icons)"
        _item "3" "$(t themes_wallpaper)"
        _item "4" "$(t themes_fonts)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1) install_dark_theme ;;
            2) install_icon_pack ;;
            3) set_wallpaper ;;
            4) install_fonts ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}
