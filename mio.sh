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
        echo "     mio sync"
        return 1
    fi

    if [[ $grupo == "sync" ]]; then
        pushd $MIO_REPO > /dev/null
        git pull origin main
        popd > /dev/null
        echo "✓ Repo sincronizado"
        return 0
    fi

    if [[ ! -d $MIO_REPO/$grupo ]]; then
        echo "Error: grupo '$grupo' no existe en el repo"
        return 1
    fi

    if [[ -z $verbo ]]; then
        echo "Error: falta el verbo"
        echo "  → mio sys list $grupo"
        return 1
    fi

    local script=$MIO_REPO/$grupo/$verbo.sh

    if [[ ! -f $script ]]; then
        echo "Error: verbo '$verbo' no encontrado en '$grupo'"
        echo "  → mio sys list $grupo"
        return 1
    fi

    # Lee runtime del wrapper, si no del group.toml, si no bash
    local runtime=$(grep "^runtime=" $script | cut -d= -f2)
    if [[ -z $runtime ]]; then
        runtime=$(grep "^runtime=" $MIO_REPO/$grupo/group.toml 2>/dev/null | cut -d= -f2)
    fi
    [[ -z $runtime ]] && runtime="bash"

    local runner=$MIO_REPO/runtimes/$runtime/run.sh
    if [[ ! -f $runner ]]; then
        echo "Error: runtime '$runtime' no encontrado"
        return 1
    fi

    bash $runner $grupo $verbo "$@"
}

[[ ! -f ~/.mio/.installed ]] && _mio_install
