#!/usr/bin/env bash

# Set up fully the test environment (except for installing required sw packages): mysql, php, composer, eZ, etc...
# Has to be useable from Docker as well as from Travis and GH-hosted runners.
# Has to be run from the project (bundle) top dir.
#
# Uses env vars: TRAVIS_PHP_VERSION, PHP_VERSION, GITHUB_ACTION

# @todo check if all required env vars have a value
# @todo support a -v option

set -e

BIN_DIR=$(dirname -- ${BASH_SOURCE[0]})

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

# BC. We should abandon either PHP_VERSION or TESTSTACK_PHP_VERSION going forward
if [ -z "${PHP_VERSION}" -a -n "${TESTSTACK_PHP_VERSION}" ]; then
    PHP_VERSION="${TESTSTACK_PHP_VERSION}"
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

${BIN_DIR}/setup/db-config.sh

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
