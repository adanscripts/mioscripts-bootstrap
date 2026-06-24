#!/bin/bash

export MIO_REPO=~/.mio/repo
export MIO_USER_EMAIL="adan@adan.adan"
export MIO_USER_NAME="adan"

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
    local grupo=$1
    local verbo=$2
    shift 2

    if [[ -z $grupo ]]; then
        echo "Uso: mio <grupo> <verbo> [args]"
        return 1
    fi

    case $grupo in
        sync)
            pushd $MIO_REPO > /dev/null
            git pull origin main
            popd > /dev/null
            echo "✓ Repo sincronizado"
            return 0
            ;;
        list)
            echo "Grupos disponibles:"
            for dir in $MIO_REPO/*/; do
                echo "  $(basename $dir)"
            done
            return 0
            ;;
    esac

    if [[ ! -d $MIO_REPO/$grupo ]]; then
        echo "Error: grupo '$grupo' no existe en el repo"
        return 1
    fi

    if [[ -z $verbo ]]; then
        echo "Verbos en $grupo:"
        for script in $MIO_REPO/$grupo/*.sh $MIO_REPO/$grupo/*.py; do
            [[ ! -f $script ]] && continue
            local filename=$(basename $script)
            local v="${filename%.*}"
            [[ $v == "load" ]] && continue
            echo "  $v"
        done
        return 0
    fi

    local script=$(ls $MIO_REPO/$grupo/$verbo.sh $MIO_REPO/$grupo/$verbo.py 2>/dev/null | head -1)

    if [[ -z $script ]]; then
        echo "Error: verbo '$verbo' no encontrado en '$grupo'"
        return 1
    fi

    local ext="${script##*.}"
    case $ext in
        sh)
            (
                source $script
                if declare -f $grupo.$verbo > /dev/null; then
                    $grupo.$verbo "$@"
                fi
            )
            ;;
        py) python3 $script "$@" ;;
    esac
}

[[ ! -f ~/.mio/.installed ]] && _mio_install
