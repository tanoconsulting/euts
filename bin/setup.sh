#!/usr/bin/env bash

# Set up fully the test environment (except for installing required sw packages): mysql, php, composer, eZ, etc...
# Has to be useable from the Docker test container as well as from Travis and GH-hosted runners.
# Has to be run from the project (bundle) top dir.
#
# Uses env vars: TRAVIS_PHP_VERSION, PHP_VERSION, GITHUB_ACTION

# @todo check if all required env vars have a value
# @todo support a -v option

set -e

BIN_DIR=$(dirname -- ${BASH_SOURCE[0]})

# @todo on Travis/GHA, if someone has loaded a .env file, the variables TESTSTACK_DEBIAN_VERSION/TESTSTACK_OS_VENDOR
#       might be set and not match what is on the VM. We could check and halt in that case, or give a warning

# For php 5.6, Composer needs humongous amounts of ram - which we don't have on Travis. Enable swap as workaround
if [ "${TRAVIS_PHP_VERSION}" = "5.6" ]; then
    echo "Setting up a swap file..."

    # @todo any other services we could stop ?
    sudo systemctl stop cron atd docker snapd mysql

    sudo fallocate -l 10G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo swapon -s

    sudo sysctl vm.swappiness=10
    sudo sysctl vm.vfs_cache_pressure=50

    #free -m
    #df -h
    #ps auxwww
    #systemctl list-units --type=service
fi

# @todo TESTSTACK_PHP_VERSION should not be set on Travis/GHA. Give a warning / halt if it is? Vice-versa, it should
#       be set (and PHP_VERSION not set) in containers.
if [ -n "${TESTSTACK_PHP_VERSION}" ]; then
    if [ -z "${PHP_VERSION}" ]; then
        export PHP_VERSION="${TESTSTACK_PHP_VERSION}"
    else
        if [ "${TESTSTACK_PHP_VERSION}" != "${PHP_VERSION}" ]; then
            printf "\n\e[31mERROR:\e[0m env var TESTSTACK_PHP_VERSION is set and different from PHP_VERSION\n\n" >&2
            exit 1
        fi
    fi
fi

if [ -n "${PHP_VERSION}" ]; then
    ${BIN_DIR}/setup/php.sh
fi

${BIN_DIR}/setup/php-config.sh

# This is done by Travis automatically... Check if on GHA we also always get the latest version
#if [ "${TRAVIS}" != "true" ]; then
#    composer selfupdate
#fi

${BIN_DIR}/setup/composer.sh

${BIN_DIR}/setup/composer-dependencies.sh

# When this is run in the test container, the db server is in another container. No need to try to configure it remotely.
# Otoh, when running on Travis or GHA, the db server runs within the same VM
if [ -n "${TRAVIS_PHP_VERSION}" -o -n "${GITHUB_ACTION}" ]; then
    ${BIN_DIR}/setup/db-config.sh
fi

# Create the database from sql files present in either the legacy stack or kernel (has to be run after composer install)
${BIN_DIR}/create-db.sh

# Set up eZ configuration files
${BIN_DIR}/setup/ez-config.sh

# TODO are these needed at all? Also: are they available / the same for every eZP version?
#${BIN_DIR}/sfconsole.sh cache:clear --no-debug
#${BIN_DIR}/sfconsole.sh assetic:dump

# TODO for eZPlatform, do we need to set up SOLR as well ?
#if [ "$EZ_VERSION" != "ezpublish" ]; then ./vendor/ezsystems/ezplatform-solr-search-engine && bin/.travis/init_solr.sh; fi

echo "Setup done"
