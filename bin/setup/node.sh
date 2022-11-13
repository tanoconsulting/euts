#!/usr/bin/env bash

# Uses env vars: NODE_VERSION

NODEVER=$(node --version 2>/dev/null | cut -d. -f1 | sed 's/v//')

if [ "${NODE_VERSION}" = default ]; then
    if [ "${NODEVER}" != '' ]; then
        NODE_VERSION="${NODEVER}"
    fi
fi

if [ "${NODEVER}" = "${NODE_VERSION}" ]; then
    echo "Found Node.js version ${NODEVER}, skipping Node.js installation"
else
    echo "Installing Node.js version ${NODE_VERSION}"

    # @todo replace `cd` with creating a var to use in place of ./
    cd "$(dirname -- "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")")"

    # @todo can we be smarter than this ? Also: is this required at all?
    if [ -f ./docker/images/ez/root/build/getnode.sh ]; then
        chmod 755 ./docker/images/ez/root/build/getnode.sh
        sudo ./docker/images/ez/root/build/getnode.sh "${NODE_VERSION}"
    elif [ -f /home/test/teststack/docker/images/ez/root/build/getnode.sh ]; then
        chmod 755 /home/test/teststack/docker/images/ez/root/build/getnode.sh
        sudo /home/test/teststack/docker/images/ez/root/build/getnode.sh "${NODE_VERSION}"
    else
        printf "\n\e[31mERROR:\e[0m Node.js version ${NODEVER} does not match required ${NODE_VERSION} and can not find script to set up Node.js\n\n" >&2
        exit 1
    fi
fi
