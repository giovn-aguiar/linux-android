#!/data/data/com.termux/files/usr/bin/bash
# lib/device.sh — Detecção de hardware e configuração de GPU
# Sourced by script-termux.sh — NÃO executar diretamente.

collect_device_info() {
    ARCH="$(uname -m)"
    DEVICE_BRAND="$(getprop ro.product.brand 2>/dev/null || echo 'Unknown')"
    DEVICE_MODEL="$(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
    GPU_INFO="$(
        {
            getprop ro.hardware.egl
            getprop ro.hardware.vulkan
            getprop ro.board.platform
            getprop ro.hardware
        } 2>/dev/null | tr '[:upper:]' '[:lower:]'
    )"

    info "$(t architecture "$ARCH")"
    info "$(t device_info "$DEVICE_BRAND" "$DEVICE_MODEL")"

    if [ "$ARCH" != "aarch64" ]; then
        warn "$(t wine_arm64_warning)"
    fi
}

choose_gpu() {
    echo ""
    echo "  -- $(t gpu_config_title) --"
    echo "   1) $(t gpu_auto)"
    echo "   2) $(t gpu_force_adreno)"
    echo "   3) $(t gpu_disable)"
    echo ""

    local gpu_option=""
    gpu_option="$(read_choice "  $(t gpu_prompt)" '1' '^[1-3]$')"

    case "$gpu_option" in
        1)
            if printf '%s' "$GPU_INFO" | grep -Eq 'adreno|qcom|qualcomm|msm'; then
                GPU_DRIVER="freedreno"
                GPU_ENABLED="true"
                ok "$(t gpu_adreno_detected)"
            else
                GPU_DRIVER="software"
                GPU_ENABLED="false"
                warn "$(t gpu_adreno_not_detected)"
            fi
        ;;
        2)
            GPU_DRIVER="freedreno"
            GPU_ENABLED="true"
            warn "$(t gpu_forced_warning)"
        ;;
        3)
            GPU_DRIVER="software"
            GPU_ENABLED="false"
            ok "$(t gpu_disabled)"
        ;;
    esac
}

install_gpu_drivers() {
    if [ "$GPU_ENABLED" = "true" ]; then
        info "$(t gpu_base_install)"
        if pkg install -y mesa-zink vulkan-loader-android >> "$LOG" 2>&1; then
            ok "$(t gpu_base_installed)"
        else
            warn "$(t gpu_base_failed)"
            GPU_ENABLED="false"
            GPU_DRIVER="software"
            return 0
        fi

        if [ "$GPU_DRIVER" = "freedreno" ]; then
            install_optional_packages mesa-vulkan-icd-freedreno vulkan-tools
        fi
    else
        ok "$(t gpu_software_mode)"
    fi
}
