#!/bin/bash

MIO_CACHE=~/.mio/cache
MIO_USER_EMAIL="tu@email.com"
MIO_USER_NAME="adan"

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

mio() {
    local action=$1
    local grupo=$2

    case $action in
        load)
            local cache=$MIO_CACHE/$grupo
            if [[ ! -d $cache ]]; then
                echo "→ Descargando $grupo..."
                # Clona repo completo en temporal y copia solo el grupo
                local tmp=$(mktemp -d)
                git clone --depth=1 $MIO_REMOTE $tmp 2>/dev/null
                cp -r $tmp/$grupo $cache
                rm -rf $tmp
            fi
            source $cache/load.sh
            ;;
        clear)
            rm -rf $MIO_CACHE/$grupo
            echo "✓ Caché limpiada: $grupo"
            ;;
    esac
}

[[ ! -f ~/.mio/.installed ]] && _mio_install
