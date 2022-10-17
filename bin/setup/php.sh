#!/usr/bin/env bash

# Uses env vars: PHP_VERSION

PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)

if [ "${PHP_VERSION}" = default ]; then
    # @todo we could make a better effort to check if the current php version is the default one from the OS
    if [ "${PHPVER}" != '' ]; then
        PHP_VERSION="${PHPVER}"
    fi
fi

if [ "${PHPVER}" = "${PHP_VERSION}" ]; then
    echo "Found php version ${PHPVER}, skipping php installation"
else
    echo "Installing php version ${PHP_VERSION}"

    cd "$(dirname -- "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")")"

    # @todo can we be smarter than this ?
    if [ -f ./docker/images/ez/root/build/getphp.sh ]; then
        chmod 755 ./docker/images/ez/root/build/getphp.sh
        sudo ./docker/images/ez/root/build/getphp.sh "${PHP_VERSION}"
    elif [ -f /home/test/teststack/docker/images/ez/root/build/getphp.sh ]; then
        chmod 755 /home/test/teststack/docker/images/ez/root/build/getphp.sh
        sudo /home/test/teststack/docker/images/ez/root/build/getphp.sh "${PHP_VERSION}"
    else
        printf "\n\e[31mERROR:\e[0m php version ${PHPVER} does not match required ${PHP_VERSION} and can not find script to set up php\n\n" >&2
        exit 1
    fi
fi
