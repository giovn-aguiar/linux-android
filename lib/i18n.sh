#!/data/data/com.termux/files/usr/bin/bash
# lib/i18n.sh — Sistema de internacionalização
# Sourced by script-termux.sh — NÃO executar diretamente.

CURRENT_LANG="${CURRENT_LANG:-pt}"
declare -gA STRINGS

# Traduz uma chave. Se houver argumentos extras, usa printf para interpolar.
# Uso:
#   t "key"               -> retorna string traduzida
#   t "key" "arg1" "arg2" -> printf com a string como template
t() {
    local key="$1"
    shift
    local template="${STRINGS[$key]:-$key}"
    if [ $# -gt 0 ]; then
        # shellcheck disable=SC2059
        printf "$template" "$@"
    else
        printf '%s' "$template"
    fi
}

# Carrega o arquivo de idioma
load_language() {
    local lang="${1:-$CURRENT_LANG}"
    local lang_file="${SCRIPT_DIR}/lang/${lang}.sh"

    if [ -f "$lang_file" ]; then
        # shellcheck disable=SC1090
        source "$lang_file"
        CURRENT_LANG="$lang"
    else
        # Fallback para inglês
        # shellcheck disable=SC1090
        source "${SCRIPT_DIR}/lang/en.sh"
        CURRENT_LANG="en"
    fi
}

choose_language() {
    echo ""
    _header "Idioma / Language"
    _item "1" "Portugues"
    _item "2" "English"
    _footer
    echo ""

    local choice=""
    read -r -p "  Opção / Option [1-2, padrão/default=1]: " choice || choice="1"
    choice="${choice:-1}"

    case "$choice" in
        1) load_language "pt" ;;
        2) load_language "en" ;;
        *) load_language "pt" ;;
    esac
}

# Detecta idioma do sistema (fallback automático)
detect_language() {
    # Primeiro checa se já tem config salva
    if [ -f "${STATE_DIR:-}/config.env" ]; then
        local saved_lang=""
        saved_lang="$(grep '^CURRENT_LANG=' "${STATE_DIR}/config.env" 2>/dev/null | cut -d'"' -f2 || true)"
        if [ -n "$saved_lang" ]; then
            load_language "$saved_lang"
            return 0
        fi
    fi

    # Detecta pelo locale do sistema
    local sys_lang="${LANG:-}"
    case "$sys_lang" in
        pt*) load_language "pt" ;;
        en*) load_language "en" ;;
        *)   load_language "pt" ;;  # Padrão: português
    esac
}
