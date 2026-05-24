#!/data/data/com.termux/files/usr/bin/bash
# lib/desktop.sh — Gerenciamento de ambientes desktop
# Sourced by script-termux.sh — NAO executar diretamente.

choose_desktop() {
    echo ""
    echo "  -- $(t desktop_title) --"
    echo "   1) $(t desktop_xfce4)"
    echo "   2) $(t desktop_lxqt)"
    echo "   3) $(t desktop_mate)"
    echo "   4) $(t desktop_kde)"
    echo ""

    DE_INPUT="$(read_choice "  $(t desktop_prompt)" '1' '^[1-4]$')"
    _set_desktop_vars "$DE_INPUT"
    ok "$(t desktop_chosen "$DE_NAME")"
}

_set_desktop_vars() {
    case "$1" in
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
}

install_desktop() {
    local pkg_name=""

    for pkg_name in "${DE_CORE_PACKAGES[@]}"; do
        install_required "$(t step_installing_desktop "$DE_NAME"): $pkg_name" "$pkg_name"
    done

    install_optional_packages "${DE_EXTRA_PACKAGES[@]}"

    if ! command_exists "$DE_COMMAND"; then
        die "$(t desktop_command_not_found "$DE_COMMAND" "$DE_NAME")"
    fi
}

remove_desktop() {
    if [ -z "$DE_NAME" ]; then
        warn "$(t desktop_none_installed)"
        return 1
    fi

    local confirm=""
    confirm="$(read_yes_no "  $(t desktop_remove_confirm "$DE_NAME")" 'n')"
    if [ "$confirm" != "y" ]; then
        return 0
    fi

    info "$(t desktop_remove "$DE_NAME")"

    case "$DE_NAME" in
        XFCE4)
            pkg remove -y xfce4 xfce4-terminal thunar mousepad >> "$LOG" 2>&1 || true
        ;;
        LXQt)
            pkg remove -y lxqt-session openbox lxqt-panel pcmanfm-qt qterminal featherpad >> "$LOG" 2>&1 || true
        ;;
        MATE)
            pkg remove -y mate-session-manager marco mate-panel mate-terminal >> "$LOG" 2>&1 || true
        ;;
        "KDE Plasma")
            pkg remove -y plasma-desktop konsole >> "$LOG" 2>&1 || true
        ;;
    esac

    pkg autoremove -y >> "$LOG" 2>&1 || true
    ok "$(t desktop_removed "$DE_NAME")"
    DE_NAME=""
    DE_COMMAND=""
    save_config
}

get_desktop_status() {
    if [ -n "$DE_NAME" ] && command_exists "$DE_COMMAND"; then
        printf '%s [OK]' "$DE_NAME"
    elif [ -n "$DE_NAME" ]; then
        printf '%s [!]' "$DE_NAME"
    else
        t status_not_installed
    fi
}

desktop_menu() {
    while true; do
        echo ""
        _header "$(t desktop_config_title)"
        printf "  |  %-36s|\n" "$(t desktop_current "$(get_desktop_status)")"
        _line
        _item "1" "$(t desktop_change)"
        _item "2" "$(t desktop_reinstall)"
        _item "3" "$(t desktop_remove)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1)
                choose_desktop
                install_desktop
                save_config
            ;;
            2)
                if [ -n "$DE_NAME" ]; then
                    install_desktop
                else
                    warn "$(t desktop_none_installed)"
                fi
            ;;
            3) remove_desktop ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}
