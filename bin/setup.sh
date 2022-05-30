#!/usr/bin/env bash

# Set up fully the test environment (except for installing required sw packages): php, mysql, eZ, etc...
# Has to be useable from Docker as well as from Travis.
# Has to be run from the project (bundle) top dir.
#
# Uses env vars: TRAVIS_PHP_VERSION, GITHUB_ACTION

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

# This is done by Travis automatically...
#if [ "${TRAVIS}" != "true" ]; then
#    composer selfupdate
#fi

if [ -n "${PHP_VERSION}" ]; then
    ${BIN_DIR}/setup/php.sh
fi

# @todo download composer if it is missing

${BIN_DIR}/setup/php-config.sh

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
