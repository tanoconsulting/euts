#!/usr/bin/env bash

# Uses env vars: PHP_VERSION

PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)

if [ "${PHPVER}" != "${PHP_VERSION}" ]; then
    cd "$(dirname -- $(dirname -- $(dirname -- ${BASH_SOURCE[0]})))"

    if [ -f ./docker/images/ez/root/build/getphp.sh ]; then
        chmod 755 ./docker/images/ez/root/build/getphp.sh
        ./docker/images/ez/root/build/getphp.sh
    else
        if [ -f /home/test/teststack/docker/images/ez/root/build/getphp.sh ]; then
            chmod 755 /home/test/teststack/docker/images/ez/root/build/getphp.sh
            /home/test/teststack/docker/images/ez/root/build/getphp.sh
        else
            echo "Error: php version ${PHPVER} does not match required ${PHP_VERSION} and can not find script to set up php" >&2
            exit 1
        fi
    fi
fi
