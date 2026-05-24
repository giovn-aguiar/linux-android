#!/data/data/com.termux/files/usr/bin/bash
# lib/apps.sh — Gerenciamento de aplicativos via catalogo
# Sourced by script-termux.sh — NAO executar diretamente.

# Categorias suportadas (devem coincidir com apps.conf)
APP_CATEGORIES=("browsers" "editors" "devtools" "multimedia" "utilities" "network")

# Mapeia categoria -> chave de traducao
declare -gA APP_CAT_KEYS
APP_CAT_KEYS[browsers]="apps_browsers"
APP_CAT_KEYS[editors]="apps_editors"
APP_CAT_KEYS[devtools]="apps_devtools"
APP_CAT_KEYS[multimedia]="apps_multimedia"
APP_CAT_KEYS[utilities]="apps_utilities"
APP_CAT_KEYS[network]="apps_network"

# Le apps de uma categoria do apps.conf
# Retorna linhas no formato: nome_exibicao|pacote
get_apps_in_category() {
    local category="$1"
    local conf_file="${SCRIPT_DIR}/apps.conf"

    if [ ! -f "$conf_file" ]; then
        return 0
    fi

    local grep_out=""
    grep_out="$(grep "^${category}|" "$conf_file" 2>/dev/null || true)"
    if [ -n "$grep_out" ]; then
        echo "$grep_out" | while IFS='|' read -r _cat name pkg; do
            printf '%s|%s\n' "$name" "$pkg"
        done
    fi
}

# Lista apps de uma categoria com status de instalacao
list_category_apps() {
    local category="$1"
    local index=1

    while IFS='|' read -r name pkg; do
        local first_pkg=""
        first_pkg="$(echo "$pkg" | awk '{print $1}')"
        if is_pkg_installed "$first_pkg"; then
            printf "   %s[x]%s %2d) %s\n" "$GREEN" "$RESET" "$index" "$name"
        else
            printf "   %s[ ]%s %2d) %s\n" "$DIM" "$RESET" "$index" "$name"
        fi
        index=$((index + 1))
    done < <(get_apps_in_category "$category")
}

# Instala app(s) de uma categoria por indice
install_category_app() {
    local category="$1"
    local indices="$2"
    local apps=()

    # Coleta todos os apps da categoria
    while IFS='|' read -r name pkg; do
        apps+=("$name|$pkg")
    done < <(get_apps_in_category "$category")

    if [ "${#apps[@]}" -eq 0 ]; then
        warn "$(t apps_none_in_category)"
        return 0
    fi

    # Se 'all' ou 'todos', instala todos
    if [[ "$indices" == "all" ]] || [[ "$indices" == "todos" ]]; then
        for entry in "${apps[@]}"; do
            local name="${entry%%|*}"
            local pkg="${entry#*|}"
            info "$(t installing "$name")"
            # shellcheck disable=SC2086
            install_with_retry $pkg || warn "$(t optional_pkg_failed "$name")"
        done
        return 0
    fi

    # Instala por indices selecionados
    local idx=""
    for idx in $indices; do
        if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#apps[@]}" ]; then
            local entry="${apps[$((idx - 1))]}"
            local name="${entry%%|*}"
            local pkg="${entry#*|}"
            info "$(t installing "$name")"
            # shellcheck disable=SC2086
            install_with_retry $pkg || warn "$(t optional_pkg_failed "$name")"
        else
            warn "$(t invalid_option): $idx"
        fi
    done
}

# Submenu de uma categoria
category_submenu() {
    local category="$1"
    local cat_name=""
    cat_name="$(t "${APP_CAT_KEYS[$category]}")"

    echo ""
    echo "  -- $cat_name --"
    echo ""
    list_category_apps "$category"
    echo ""

    local selection=""
    read -r -p "  $(t apps_select_prompt)" selection || selection=""

    if [ -n "$selection" ]; then
        install_category_app "$category" "$selection"
    fi
}

# Menu principal de aplicativos
apps_menu() {
    while true; do
        echo ""
        _header "$(t apps_title)"

        local i=1
        for cat in "${APP_CATEGORIES[@]}"; do
            local cat_name=""
            cat_name="$(t "${APP_CAT_KEYS[$cat]}")"
            _item "$i" "$cat_name"
            i=$((i + 1))
        done

        _item "7" "$(t apps_install_all)"
        _item "0" "$(t back)"
        _footer
        echo ""

        local choice=""
        read -r -p "  $(t menu_prompt)" choice || choice="0"

        case "$choice" in
            [1-6])
                local cat_index=$((choice - 1))
                if [ "$cat_index" -lt "${#APP_CATEGORIES[@]}" ]; then
                    category_submenu "${APP_CATEGORIES[$cat_index]}"
                fi
            ;;
            7)
                info "$(t apps_install_all)..."
                for cat in "${APP_CATEGORIES[@]}"; do
                    install_category_app "$cat" "all"
                done
            ;;
            0) return ;;
            *) warn "$(t menu_invalid)" ;;
        esac

        pause_prompt
    done
}

# Instalacao de apps basicos (usado na instalacao completa)
install_basic_apps() {
    install_required "$(t apps_basic_tools)" git wget curl python nano tar unzip zip openssl
    install_optional_packages neofetch vlc firefox code-oss wol
}
