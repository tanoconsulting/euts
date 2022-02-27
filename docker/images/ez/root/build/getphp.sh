#!/bin/sh

# Has to be run as admin

# @todo make it optional to install xdebug. It is fe. missing in sury's ppa for Xenial
# @todo optionally install fpm
# @todo make it optional to disable xdebug ?
# @todo install phpredis
# @todo this file can now be used outside of docker. Check that os is debian/ubuntu before trying to install php

set -e

# install php
PHP_VERSION="$1"
# We prefer /etc/os-release to `lsb_release -s -c`
DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION_CODENAME=' | sed 's/VERSION_CODENAME=//')

if [ "${PHP_VERSION}" = default ]; then
    if [ "${DEBIAN_VERSION}" = jessie -o "${DEBIAN_VERSION}" = precise -o "${DEBIAN_VERSION}" = trusty ]; then
        PHPSUFFIX=5
    else
        PHPSUFFIX=
    fi
    if [ "${DEBIAN_VERSION}" = jessie ]; then
        EXTRA_PACKAGES=php5-xsl
    else
        EXTRA_PACKAGES="php-mbstring php-xsl"
    fi
    # @todo check for mbstring presence in php5 (jessie) packages
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php${PHPSUFFIX} \
        php${PHPSUFFIX}-cli \
        php${PHPSUFFIX}-curl \
        php${PHPSUFFIX}-gd \
        php${PHPSUFFIX}-intl \
        php${PHPSUFFIX}-json \
        php${PHPSUFFIX}-memcached \
        php${PHPSUFFIX}-mysql \
        php${PHPSUFFIX}-pgsql \
        php${PHPSUFFIX}-xdebug \
        ${EXTRA_PACKAGES}
else
    # On GHA runners ubuntu version, php 7.4 and 8.0, possibly more seem to be preinstalled.We remove them if found.
    # NB: this takes quite some time to execute. Should we make this optional ? Or even, try to swap the default php
    # version in use
    for PHP_CURRENT in $(dpkg -l | grep -E 'php.+-common' | awk '{print $2}'); do
        if [ "${PHP_CURRENT}" != "php${PHP_VERSION}-common" ]; then
            apt-get purge -y "${PHP_CURRENT}"
        fi
    done

    DEBIAN_FRONTEND=noninteractive apt-get install -y language-pack-en-base software-properties-common
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php${PHP_VERSION} \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-memcached \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-xdebug

    update-alternatives --set php /usr/bin/php${PHP_VERSION}
fi

#PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)

php -v
