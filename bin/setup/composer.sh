#!/usr/bin/env bash

# @todo allow usage of env var COMPOSER_VERSION to decide the version of composer to use and if we want to selfupdate

echo "Setting up Composer..."

INSTALL_COMPOSER=false

which composer 2>/dev/null
if [ $? -ne 0 ]; then
    INSTALL_COMPOSER=true
else
    # We might have to downgrade composer, in case it was already installed and we manually downgraded php to a version
    # it does not support
    PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)
    if [ "$PHPVER" = '5.6' -o "$PHPVER" = '7.0' -o "$PHPVER" = '7.1' ]; then
        # @todo be smarter - this will break with composer 2.4 and up
        CV=$(composer --version | grep -F '2.3.' 2>/dev/null)
        if [ -n "$CV" ];  then
            # q: would it be better to remove it via apt?
            sudo rm $(which composer)
            INSTALL_COMPOSER=true
        fi
    fi
fi

if [ $INSTALL_COMPOSER = true ]; then
    cd "$(dirname -- $(dirname -- $(dirname -- ${BASH_SOURCE[0]})))"
    # @todo does this work in docker-stack envs? See php.sh for a different take...
    chmod 755 ./docker/images/ez/root/build/getcomposer.sh
    sudo ./docker/images/ez/root/build/getcomposer.sh
fi

echo Done
