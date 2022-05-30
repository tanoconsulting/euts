#!/bin/sh

# Installs Composer (latest version, to avoid relying on old ones bundled with the OS)

# @todo support a different target install dir

COMPOSER_VERSION="$1"
if [ -n "${COMPOSER_VERSION}" ]; then
    COMPOSER_VERSION="--${COMPOSER_VERSION}"
else
    PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)
    if [ "$PHPVER" = '5.6' -o "$PHPVER" = '7.0' -o "$PHPVER" = '7.1' ]; then
        COMPOSER_VERSION='--2.2'
    fi
fi

EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php $COMPOSER_VERSION --install-dir=/usr/local/bin --filename=composer
RESULT=$?
rm composer-setup.php
exit $RESULT
