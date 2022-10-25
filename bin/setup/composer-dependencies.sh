#!/usr/bin/env bash

# Install dependencies using Composer
# We do not rely on the requirements set in composer.json, but install a different eZ version depending on the test matrix (env vars)
#
# Uses env vars: EZ_COMPOSER_LOCK, EZ_PACKAGES, COMPOSE_PROJECT_NAME, TRAVIS

# @todo generate and echo a hash which can be used to determine in the future if we need to run composer again (as it
#       would install different packages compared to the ones installed currently)

set -e

# Avoid spending time on composer if install will later fail
if [ ! -d "vendor" -a -L "vendor" ]; then
    printf "\n\e[31mERROR:\e[0m vendor folder is not a symlink\n\n" >&2
    exit 1
fi

# Set composer auth if we are passed env vars. This helps fe. in avoiding rate limitation limits on GitHub.
# Code thanks to shivammathur/setup-php
composer_auth=()
if [ -n "$PACKAGIST_TOKEN" ]; then
    composer_auth+=( '"http-basic": {"repo.packagist.com": { "username": "token", "password": "'"$PACKAGIST_TOKEN"'"}}' )
fi
if [ -n "$GITHUB_TOKEN" ]; then
    composer_auth+=( '"github-oauth": {"github.com": "'"$GITHUB_TOKEN"'"}' )
fi
if ((${#composer_auth[@]})); then
    if [ -n "$COMPOSER_AUTH" ]; then
        printf "\n\e[31mERROR:\e[0m COMPOSER_AUTH env var is set as well as PACKAGIST_TOKEN or GITHUB_TOKEN\n\n" >&2
        exit 1
    fi
    export COMPOSER_AUTH="{$(IFS=$','; echo "${composer_auth[*]}")}"
fi

# For the moment, to install eZPlatform, a set of DEV packages has to be allowed (eg roave/security-advisories); really
# ugly sed expression to alter composer.json follows
# A different work around for this has been found in setting up an alias for them in the std composer.json require-dev section
#- 'if [ "$EZ_VERSION" != "ezpublish" ]; then sed -i ''s/"license": "GPL-2.0",/"license": "GPL-2.0", "minimum-stability": "dev", "prefer-stable": true,/'' composer.json; fi'

# Set up a custom composer.json file if needed
if [ -n "${COMPOSE_PROJECT_NAME}" ]; then
    export COMPOSER="composer_${COMPOSE_PROJECT_NAME}.json"
    if [ -f composer.json ]; then
        cp composer.json "${COMPOSER}"
    else
        if [ ! -f "${COMPOSER}" ]; then
            printf "\n\e[31mERROR:\e[0m ${COMPOSER} file can not be found\n\n" >&2
            exit 1
        fi
    fi
else
    if [ ! -f composer.json ]; then
        printf "\n\e[31mERROR:\e[0m composer.json file can not be found\n\n" >&2
        exit 1
    fi
fi

# Allow installing a precomputed set of packages. Useful to save memory, eg. for running with php 5.6...
if [ -n "${EZ_COMPOSER_LOCK}" ]; then
    echo "Installing packages via Composer using existing lock file ${EZ_COMPOSER_LOCK}..."

    if [ ! -f "${EZ_COMPOSER_LOCK}" ]; then
        printf "\n\e[31mERROR:\e[0m lock file can not be found\n\n" >&2
        exit 1
    fi

    if [ -n "${COMPOSE_PROJECT_NAME}" ]; then
        export COMPOSER="composer_${COMPOSE_PROJECT_NAME}.json"
        cp "${EZ_COMPOSER_LOCK}" "composer_${COMPOSE_PROJECT_NAME}.lock"
    else
        cp "${EZ_COMPOSER_LOCK}" composer.lock
    fi

    composer install --no-interaction
else
    echo "Installing packages via Composer: the ones in composer.json plus ${EZ_PACKAGES}..."

    if [ -n "${COMPOSE_PROJECT_NAME}" ]; then
        if [ -f "composer_${COMPOSE_PROJECT_NAME}.lock" ]; then
            rm "composer_${COMPOSE_PROJECT_NAME}.lock"
        fi
    else
        if [ -f "composer.lock" ]; then
            rm "composer.lock"
        fi
    fi

    # we split require from update to (hopefully) save some ram
    composer require --no-interaction --dev --no-update ${EZ_PACKAGES}
    composer update --no-interaction
fi

echo Done

if [ "${TRAVIS}" = "true" ]; then
    # useful for troubleshooting tests failures
    composer show
fi
