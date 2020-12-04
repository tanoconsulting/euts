#!/usr/bin/env bash

# Install dependencies using Composer
# We do not rely on the requirements set in composer.json, but install a different eZ version depending on the test matrix (env vars)
#
# Uses env vars: EZ_COMPOSER_LOCK, EZ_PACKAGES, TESTSTACK_PROJECT_NAME, TRAVIS

# @todo generate and echo a hash which can be used to determine in the future if we need to run composer again (as it
#       would install different packages compared to the ones installed currently)

set -e

# Avoid spending time on composer if install will later fail
if [ ! -d "vendor" ]; then
    printf "\n\e[31mERROR:\e[0m vendor folder is not a symlink\n\n"
    exit 1
fi

# For the moment, to install eZPlatform, a set of DEV packages has to be allowed (eg roave/security-advisories); really ugly sed expression to alter composer.json follows
# A different work around for this has been found in setting up an alias for them in the std composer.json require-dev section
#- 'if [ "$EZ_VERSION" != "ezpublish" ]; then sed -i ''s/"license": "GPL-2.0",/"license": "GPL-2.0", "minimum-stability": "dev", "prefer-stable": true,/'' composer.json; fi'

# Allow installing a precomputed set of packages. Useful to save memory, eg. for running with php 5.6...
if [ -n "${EZ_COMPOSER_LOCK}" ]; then
    echo "Installing packages via Composer using existing lock file ${EZ_COMPOSER_LOCK}..."

    cp ${EZ_COMPOSER_LOCK} composer.lock
    composer install
else
    echo "Installing packages via Composer: the ones in composer.json plus ${EZ_PACKAGES}..."

    if [ -n "${TESTSTACK_PROJECT_NAME}" ]; then
        export COMPOSER="composer_${TESTSTACK_PROJECT_NAME}.json"
        cp composer.json ${COMPOSER}
    fi
    # we split require from update to (hopefully) save some ram
    composer require --dev --no-update ${EZ_PACKAGES}
    composer update
fi

echo Done

if [ "${TRAVIS}" = "true" ]; then
    # useful for troubleshooting tests failures
    composer show
fi
