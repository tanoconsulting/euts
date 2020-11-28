#!/usr/bin/env bash

# Set up PHP configuration files
#
# Uses env vars: TRAVIS

set -e

STACK_DIR=$(dirname -- $(dirname -- $(dirname -- ${BASH_SOURCE[0]})))

echo "Setting up php configuration..."

# Increase php memory limit (need to do this now or we risk composer failing)
if [ "${TRAVIS}" = "true" ]; then
    phpenv config-add ${STACK_DIR}/config/php/zzz_php.ini
else
    INI_PATH=$(php -i | grep 'Scan this dir for additional .ini files')
    INI_PATH=${INI_PATH/Scan this dir for additional .ini files => /}
    sudo cp ${STACK_DIR}/config/php/zzz_php.ini ${INI_PATH}
fi

# Disable xdebug for speed (both for executing composer and running tests); we enable it only when generating code coverage
XDEBUG_INI=$(php -i | grep xdebug.ini | grep -v '=>' | head -1)
XDEBUG_INI=${XDEBUG_INI/,/}
if [ "${XDEBUG_INI}" != "" ]; then
    sudo mv "${XDEBUG_INI}" "${XDEBUG_INI}.off";
fi
