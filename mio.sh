#!/bin/bash

MIO_REPO=~/.mio/repo
MIO_USER_EMAIL="adan@adan.adan"
MIO_USER_NAME="adan"

_mio_install() {
    mkdir -p ~/.mio

    git config --global user.email "$MIO_USER_EMAIL"
    git config --global user.name "$MIO_USER_NAME"

    read -s -p "GitHub token: " MIO_TOKEN
    echo
    export MIO_REMOTE="https://${MIO_TOKEN}@github.com/adanscripts/mioscripts"

    if [[ ! -d $MIO_REPO ]]; then
        echo "→ Clonando repo..."
        git clone $MIO_REMOTE $MIO_REPO
        git config --global --add safe.directory $MIO_REPO
    fi

    touch ~/.mio/.installed
    echo "✓ mio instalado"
}

mio() {
    local action=$1
    local grupo=$2

    case $action in
        load)
            if [[ ! -d $MIO_REPO/$grupo ]]; then
                echo "Error: grupo '$grupo' no existe en el repo"
                return 1
            fi
            source $MIO_REPO/$grupo/load.sh
            ;;
        clear)
            echo "✓ No hay caché, el repo es la fuente de verdad"
            ;;
        sync)
            cd $MIO_REPO
            git pull origin main
            cd -
            echo "✓ Repo sincronizado"
            ;;
    esac
}

[[ ! -f ~/.mio/.installed ]] && _mio_install
