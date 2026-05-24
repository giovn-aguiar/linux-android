#!/data/data/com.termux/files/usr/bin/bash
# Ponto de entrada modular para Configuração do Termux Linux/X11
# Entrypoint for Termux Linux/X11 Configuration

set -Eeuo pipefail
IFS=$'\n\t'

# Define o diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# 1. Carrega o core (common e i18n)
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/i18n.sh"

# 2. Carrega todos os outros módulos de biblioteca
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/checks.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/device.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/desktop.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/apps.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/wine.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/themes.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/scripts.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/backup.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/menu.sh"

# Armadilha de erro configurada no common.sh
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR
trap '_stop_spinner' EXIT

# Processamento de flags da CLI
show_help() {
    echo "Uso / Usage: ./script-termux.sh [opções / options]"
    echo ""
    echo "Opções / Options:"
    echo "  --help, -h          Mostra esta mensagem de ajuda / Show this help message"
    echo "  --install           Inicia a instalação completa automática / Start automated full installation"
    echo "  --desktop [de]      Instala um desktop específico (xfce4, lxqt, mate, kde) / Install specific desktop"
    echo "  --app [nome]        Instala um aplicativo específico do catálogo / Install a specific app from catalog"
    echo "  --lang [pt|en]      Força o idioma do script / Force script language"
    echo ""
    exit 0
}

# Define variáveis para as ações CLI
ACTION="menu"
DESKTOP_ARG=""
APP_ARG=""
FORCE_LANG=""

# Processamento de argumentos
while (( "$#" )); do
    case "$1" in
        -h|--help)
            show_help
            ;;
        --install)
            ACTION="install"
            shift
            ;;
        --desktop)
            ACTION="desktop"
            if [ -n "${2:-}" ]; then
                DESKTOP_ARG="$2"
                shift 2
            else
                echo "Erro: Faltou especificar o desktop (xfce4, lxqt, mate, kde)." >&2
                exit 1
            fi
            ;;
        --app)
            ACTION="app"
            if [ -n "${2:-}" ]; then
                APP_ARG="$2"
                shift 2
            else
                echo "Erro: Faltou especificar o nome do aplicativo." >&2
                exit 1
            fi
            ;;
        --lang)
            if [ -n "${2:-}" ]; then
                FORCE_LANG="$2"
                shift 2
            else
                echo "Erro: Faltou especificar o idioma (pt, en)." >&2
                exit 1
            fi
            ;;
        *)
            echo "Erro: Flag não suportada / Unsupported flag: $1" >&2
            show_help
            ;;
    esac
done

# Inicialização e detecção de idioma
load_config || true

if [ -n "$FORCE_LANG" ]; then
    case "$FORCE_LANG" in
        pt|en) load_language "$FORCE_LANG" ;;
        *)     echo "Idioma inválido. Opções: pt, en. / Invalid language. Options: pt, en." >&2; exit 1 ;;
    esac
else
    detect_language
fi

# Agora executa a verificação obrigatória de ambiente
require_termux

# Executa a ação selecionada
case "$ACTION" in
    install)
        full_install
        ;;
    desktop)
        case "$(echo "$DESKTOP_ARG" | tr '[:upper:]' '[:lower:]')" in
            xfce4) _set_desktop_vars 1 ;;
            lxqt)  _set_desktop_vars 2 ;;
            mate)  _set_desktop_vars 3 ;;
            kde)   _set_desktop_vars 4 ;;
            *)     die "Desktop inválido. Opções: xfce4, lxqt, mate, kde." ;;
        esac
        install_desktop
        save_config
        ;;
    app)
        # Procura o app no catálogo apps.conf
        app_found=false
        app_pkg=""
        app_name=""
        while IFS='|' read -r _cat name pkg; do
            clean_name="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
            clean_pkg="$(echo "$pkg" | tr '[:upper:]' '[:lower:]')"
            target_arg="$(echo "$APP_ARG" | tr '[:upper:]' '[:lower:]')"
            if [[ "$clean_name" == *"$target_arg"* ]] || [[ "$clean_pkg" == *"$target_arg"* ]]; then
                app_pkg="$pkg"
                app_name="$name"
                app_found=true
                break
            fi
        done < "${SCRIPT_DIR}/apps.conf"

        if [ "$app_found" = true ]; then
            info "$(t installing "$app_name")"
            # shellcheck disable=SC2086
            install_with_retry $app_pkg || die "$(t optional_pkg_failed "$app_name")"
        else
            die "Aplicativo '$APP_ARG' não encontrado no catálogo apps.conf."
        fi
        ;;
    menu)
        # Se for a primeira execução (sem desktop configurado no config.env), perguntar o idioma primeiro.
        if [ -z "${DE_NAME:-}" ] && [ ! -f "${STATE_DIR}/config.env" ]; then
            choose_language
        fi
        main_menu
        ;;
esac
