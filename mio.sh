#!/bin/bash

# ── CONFIGURACIÓN ──────────────────────────
MIO_CACHE=~/.mio/cache
MIO_USER_EMAIL="adan@email.com"
MIO_USER_NAME="adan"

# ── INSTALACIÓN ────────────────────────────
_mio_install() {
    mkdir -p $MIO_CACHE
    mkdir -p ~/bin

    git config --global user.email "$MIO_USER_EMAIL"
    git config --global user.name "$MIO_USER_NAME"
    git config --global --add safe.directory "$MIO_CACHE"

    read -s -p "GitHub token: " MIO_TOKEN
    echo
    export MIO_REMOTE="https://${MIO_TOKEN}@github.com/adanscripts/mioscripts"

    touch ~/.mio/.installed
    echo "✓ mio instalado"
}

# ── DISPATCHER ─────────────────────────────
mio() {
    local action=$1
    local grupo=$2

    case $action in
        load)
            local cache=$MIO_CACHE/$grupo
            if [[ ! -d $cache ]]; then
                echo "→ Descargando $grupo..."
                git clone --depth=1 $MIO_REMOTE $cache 2>/dev/null
            fi
            source $cache/$grupo/load.sh
            ;;
        clear)
            rm -rf $MIO_CACHE/$grupo
            echo "✓ Caché limpiada: $grupo"
            ;;
    esac
}

# ── ARRANQUE ───────────────────────────────
[[ ! -f ~/.mio/.installed ]] && _mio_install
