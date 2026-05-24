#!/data/data/com.termux/files/usr/bin/bash
# lib/menu.sh — Sistema de menus interativo
# Sourced by script-termux.sh — NAO executar diretamente.

# =========================
# Helpers de desenho de menu
# =========================
_line() {
    echo "  +--------------------------------------+"
}

_header() {
    _line
    printf "  |  %-36s|\n" "$1"
    _line
}

_item() {
    printf "  |  %s) %-33s|\n" "$1" "$2"
}

_footer() {
    _line
}

# =========================
# Banner com status
# =========================
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
    _header "$(t banner_title)"

    # Mostrar status se tiver config carregada
    if [ -n "$DE_NAME" ] || [ "$GPU_ENABLED" = "true" ]; then
        echo ""
        printf "  %s%-10s%s %s\n" "$DIM" "$(t banner_status_desktop):" "$RESET" "$(get_desktop_status)"
        if [ "$GPU_ENABLED" = "true" ]; then
            printf "  %s%-10s%s %s (%s)\n" "$DIM" "$(t banner_status_gpu):" "$RESET" "$GPU_DRIVER" "$(t status_enabled)"
        else
            printf "  %s%-10s%s software (%s)\n" "$DIM" "$(t banner_status_gpu):" "$RESET" "$(t status_disabled)"
        fi
        printf "  %s%-10s%s %s\n" "$DIM" "$(t banner_status_wine):" "$RESET" "$(get_wine_status)"
    fi

    echo ""
}

# =========================
# Audio
# =========================
audio_menu() {
    while true; do
        echo ""
        _header "$(t audio_title)"
        _item "1" "$(t audio_install)"
        _item "2" "$(t audio_restart)"
        _item "3" "$(t audio_status)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1)
                install_required "$(t audio_install)" pulseaudio
                ok "$(t audio_installed)"
            ;;
            2)
                pulseaudio --kill >/dev/null 2>&1 || true
                pulseaudio --start --exit-idle-time=-1 >> "$LOG" 2>&1 || true
                ok "$(t audio_restarted)"
            ;;
            3)
                if pgrep -x pulseaudio >/dev/null 2>&1; then
                    ok "$(t audio_running)"
                else
                    warn "$(t audio_not_running)"
                fi
            ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}

# =========================
# GPU (submenu)
# =========================
gpu_menu() {
    choose_gpu
    install_gpu_drivers
    save_config
    pause_prompt
}

# =========================
# Manutencao
# =========================
check_integrity() {
    local missing=0
    local cmds_to_check=(termux-x11 pulseaudio)

    if [ -n "$DE_COMMAND" ]; then
        cmds_to_check+=("$DE_COMMAND")
    fi

    for cmd in "${cmds_to_check[@]}"; do
        if command_exists "$cmd"; then
            ok "$cmd -- $(t maint_found)"
        else
            warn "$cmd -- $(t maint_not_found)"
            missing=$((missing + 1))
        fi
    done

    echo ""
    if [ "$missing" -gt 0 ]; then
        warn "$(t maint_components_missing "$missing")"
    else
        ok "$(t maint_all_ok)"
    fi
}

maintenance_menu() {
    while true; do
        echo ""
        _header "$(t maint_title)"
        _item "1" "$(t maint_update)"
        _item "2" "$(t maint_check_integrity)"
        _item "3" "$(t maint_view_install_log)"
        _item "4" "$(t maint_view_start_log)"
        _item "5" "$(t maint_clean_cache)"
        _item "6" "$(t maint_recreate_scripts)"
        _item "7" "$(t maint_diagnostics)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1)
                info "$(t maint_updating)"
                run_cmd "pkg update" pkg update -y
                run_cmd "pkg upgrade" pkg upgrade -y
                ok "$(t maint_updated)"
            ;;
            2) check_integrity ;;
            3)
                echo ""
                if [ -s "$LOG" ]; then
                    tail -n 50 "$LOG" | sed 's/^/    /'
                else
                    warn "Log vazio."
                fi
            ;;
            4)
                echo ""
                if [ -s "$START_LOG" ]; then
                    tail -n 50 "$START_LOG" | sed 's/^/    /'
                else
                    warn "Log vazio."
                fi
            ;;
            5)
                info "$(t maint_clean_cache)..."
                pkg clean >> "$LOG" 2>&1 || true
                apt autoclean >> "$LOG" 2>&1 || true
                ok "$(t maint_cache_cleaned)"
            ;;
            6)
                if [ -n "$DE_NAME" ]; then
                    write_all_scripts
                else
                    warn "$(t desktop_none_installed)"
                fi
            ;;
            7)
                if [ -x "${HOME}/linux-info.sh" ]; then
                    bash "${HOME}/linux-info.sh"
                else
                    check_integrity
                fi
            ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}

# =========================
# Instalacao Completa (fluxo linear original)
# =========================
full_install() {
    banner

    info "$(t checking_internet)"
    check_internet || die "$(t no_internet)"

    collect_device_info
    choose_gpu
    choose_desktop

    echo ""
    local wine_answer=""
    wine_answer="$(read_yes_no "  $(t wine_install_prompt)" 'n')"
    if [ "$wine_answer" = "y" ]; then
        INSTALL_WINE="y"
    fi

    : > "$LOG"

    start_step "$(t step_preparing)"
    prepare_environment
    wait_package_manager
    run_cmd "corrigir dpkg pendente" dpkg --configure -a
    end_step

    start_step "$(t step_updating)"
    run_cmd "pkg update" pkg update -y
    run_cmd "pkg upgrade" pkg upgrade -y
    end_step

    start_step "$(t step_adding_repos)"
    install_required "repositorios" x11-repo tur-repo
    run_cmd "atualizar lista apos repositorios" pkg update -y
    end_step

    start_step "$(t step_graphics_server)"
    install_any_required "Termux-X11" termux-x11 termux-x11-nightly
    install_required "ferramentas X11" xorg-xrandr xorg-xhost xorg-xsetroot
    end_step

    start_step "$(t step_installing_desktop "$DE_NAME")"
    install_desktop
    end_step

    start_step "$(t step_configuring_gpu)"
    install_gpu_drivers
    end_step

    start_step "$(t step_installing_audio)"
    install_required "audio" pulseaudio
    end_step

    start_step "$(t step_installing_apps)"
    install_basic_apps
    end_step

    start_step "$(t step_configuring_wine)"
    install_wine_if_requested
    end_step

    start_step "$(t step_creating_scripts)"
    write_start_script
    write_stop_script
    write_info_script
    save_config
    end_step

    start_step "$(t step_creating_shortcuts)"
    create_desktop_shortcuts
    end_step

    _stop_spinner
    echo ""
    if command_exists neofetch; then
        neofetch || true
    fi

    echo ""
    _header "$(t install_complete)"
    echo ""
    echo "  $(t install_desktop_label) : $DE_NAME"
    echo "  $(t install_gpu_label)     : $GPU_DRIVER / enabled=$GPU_ENABLED"
    echo ""
    echo "  $(t install_start_cmd) : ~/start-linux.sh"
    echo "  $(t install_stop_cmd)   : ~/stop-linux.sh"
    echo "  $(t install_info_cmd)    : ~/linux-info.sh"
    echo "  $(t install_log_label)     : $LOG"
    echo ""
    echo "  $(t install_open_x11)"
    echo ""
}

# =========================
# Menu principal
# =========================
main_menu() {
    while true; do
        banner

        _header "$(t menu_title)"
        _item "1" "$(t menu_full_install)"
        _item "2" "$(t menu_apps)"
        _item "3" "$(t menu_desktop)"
        _item "4" "$(t menu_gpu)"
        _item "5" "$(t menu_audio)"
        _item "6" "$(t menu_wine)"
        _item "7" "$(t menu_themes)"
        _item "8" "$(t menu_maintenance)"
        _item "9" "$(t menu_backup)"
        _item "0" "$(t menu_exit)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1) full_install ; pause_prompt ;;
            2) apps_menu ;;
            3) desktop_menu ;;
            4) gpu_menu ;;
            5) audio_menu ;;
            6) wine_menu ;;
            7) themes_menu ;;
            8) maintenance_menu ;;
            9) backup_menu ;;
            0)
                echo ""
                echo "  $(t menu_goodbye)"
                echo ""
                exit 0
            ;;
            *) warn "$(t menu_invalid)" ; sleep 1 ;;
        esac
    done
}
