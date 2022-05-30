#!/usr/bin/env bash

# @todo allow usage of env var COMPOSER_VERSION to decide the version of composer to use and if we want to selfupdate

echo "Setting up Composer..."

which composer 2>/dev/null
if [ $? -ne 0 ]; then
    chmod 755 /home/test/teststack/docker/images/ez/root/build/getcomposer.sh
    sudo /home/test/teststack/docker/images/ez/root/build/getcomposer.sh
else
    # We might have to downgrade composer, in case it was already installed and we manually downgraded php
    PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)
    if [ "$PHPVER" = '5.6' -o "$PHPVER" = '7.0' -o "$PHPVER" = '7.1' ]; then
        composer selfupdate --2.2
    fi
fi

echo Done
