#!/usr/bin/env bash

# @todo allow usage of env var COMPOSER_VERSION to decide the version of composer to use and/or if we want to selfupdate

echo "Setting up Composer..."

INSTALL_COMPOSER=false

# @todo what if `which` is not installed?
if which composer >/dev/null 2>/dev/null; then
    # We might have to downgrade composer, in case it was already installed and we manually downgraded php to a version
    # it does not support.
    # NB: take care when Composer 2.5 and later are out: they might not support php 7.2, etc...
    PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)
    if [ "$PHPVER" = '5.6' -o "$PHPVER" = '7.0' -o "$PHPVER" = '7.1' ]; then
        CV=$(composer --version | grep -E '2\.[3456789]\.' 2>/dev/null)
        if [ -n "$CV" ];  then
            # q: would it be better to remove it via apt?
            sudo rm "$(which composer)"
            INSTALL_COMPOSER=true
        fi
    fi
else
    INSTALL_COMPOSER=true
fi

if [ $INSTALL_COMPOSER = true ]; then
    # @todo replace `cd` with creating a var to use in place of ./
    cd "$(dirname -- "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")")"
    # @todo does this work in docker-stack envs? See php.sh for a different take...
    chmod 755 ./docker/images/ez/root/build/getcomposer.sh
    sudo ./docker/images/ez/root/build/getcomposer.sh
    if [ -d "$HOME/.cache/composer" ]; then
        sudo chown -R "$(id -u)" "$HOME/.cache/composer"
    fi
fi

echo Done
