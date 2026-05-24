#!/data/data/com.termux/files/usr/bin/bash
# lib/backup.sh — Backup e restauração de configuração
# Sourced by script-termux.sh — NÃO executar diretamente.

BACKUP_DIR="${STATE_DIR}/backups"

backup_save() {
    mkdir -p "$BACKUP_DIR"

    local timestamp=""
    timestamp="$(date '+%Y%m%d_%H%M%S')"
    local backup_path="${BACKUP_DIR}/backup_${timestamp}"
    mkdir -p "$backup_path"

    # Salva config atual
    if [ -f "${STATE_DIR}/config.env" ]; then
        cp "${STATE_DIR}/config.env" "$backup_path/"
    fi

    # Salva scripts gerados
    for script in start-linux.sh stop-linux.sh linux-info.sh; do
        if [ -f "${HOME}/${script}" ]; then
            cp "${HOME}/${script}" "$backup_path/"
        fi
    done

    # Salva configurações de desktop (XFCE4)
    if [ -d "${HOME}/.config/xfce4" ]; then
        cp -r "${HOME}/.config/xfce4" "$backup_path/" 2>/dev/null || true
    fi

    # Salva configurações de Termux
    if [ -d "${HOME}/.termux" ]; then
        cp -r "${HOME}/.termux" "$backup_path/dot-termux" 2>/dev/null || true
    fi

    ok "$(t backup_saved "$backup_path")"
}

backup_restore() {
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        warn "$(t backup_not_found)"
        return 1
    fi

    echo ""
    echo "  $(t backup_list)"
    echo ""

    local backups=()
    local i=1
    local dir=""

    for dir in "$BACKUP_DIR"/backup_*; do
        if [ -d "$dir" ]; then
            local name=""
            name="$(basename "$dir")"
            backups+=("$dir")
            printf "   %d) %s\n" "$i" "$name"
            i=$((i + 1))
        fi
    done

    if [ "${#backups[@]}" -eq 0 ]; then
        warn "$(t backup_not_found)"
        return 1
    fi

    echo ""
    local choice=""
    read -r -p "  $(t backup_select)" choice || return

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#backups[@]}" ]; then
        local selected="${backups[$((choice - 1))]}"

        # Restaura config.env
        if [ -f "$selected/config.env" ]; then
            cp "$selected/config.env" "${STATE_DIR}/"
            load_config
        fi

        # Restaura scripts
        for script in start-linux.sh stop-linux.sh linux-info.sh; do
            if [ -f "$selected/$script" ]; then
                cp "$selected/$script" "${HOME}/"
                chmod +x "${HOME}/${script}"
            fi
        done

        # Restaura configs de desktop
        if [ -d "$selected/xfce4" ]; then
            mkdir -p "${HOME}/.config"
            cp -r "$selected/xfce4" "${HOME}/.config/" 2>/dev/null || true
        fi

        # Restaura configs de Termux
        if [ -d "$selected/dot-termux" ]; then
            cp -r "$selected/dot-termux" "${HOME}/.termux" 2>/dev/null || true
        fi

        ok "$(t backup_restored "$selected")"
    else
        warn "$(t invalid_option)"
    fi
}

backup_export() {
    local export_dir=""
    export_dir="$(t backup_export_path)"
    mkdir -p "$export_dir"

    local timestamp=""
    timestamp="$(date '+%Y%m%d_%H%M%S')"
    local export_file="${export_dir}/termux-linux-backup_${timestamp}.tar.gz"

    if [ -d "$STATE_DIR" ]; then
        tar -czf "$export_file" -C "$HOME" \
            ".termux-linux" \
            "start-linux.sh" \
            "stop-linux.sh" \
            "linux-info.sh" \
            2>/dev/null || true
        ok "$(t backup_exported "$export_file")"
    else
        warn "$(t backup_not_found)"
    fi
}

backup_menu() {
    while true; do
        echo ""
        _header "$(t backup_title)"
        _item "1" "$(t backup_save)"
        _item "2" "$(t backup_restore)"
        _item "3" "$(t backup_export)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            1) backup_save ;;
            2) backup_restore ;;
            3) backup_export ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}
