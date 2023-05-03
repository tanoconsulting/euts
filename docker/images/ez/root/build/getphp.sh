#!/bin/sh

# Has to be run as admin

# @todo make it optional to install xdebug. It is fe. missing in sury's ppa for Xenial
# @todo optionally install fpm
# @todo make it optional to disable xdebug ?
# @todo install phpredis
# @todo this file can now be used outside of docker. Check that os is debian/ubuntu before trying to install php
# @todo test the matrix of ubuntu versions (xenial, bionic, focal, jammy) vs. all php versions incl. 'default'

echo "Installing the required php version..."

set -e

# install php
PHP_VERSION="$1"

if [ -z "${PHP_VERSION}" ]; then
    printf "\n\e[31mERROR:\e[0m unknown PHP version to install\n\n" >&2
    exit 1
fi

DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION_CODENAME=' | sed 's/VERSION_CODENAME=//')
if [ -z "${DEBIAN_VERSION}" ]; then
    DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION=' | grep 'VERSION=' | sed 's/VERSION=//' | sed 's/"[0-9.]\+ *(\?//' | sed 's/)\?"//' | tr '[:upper:]' '[:lower:]' | sed 's/lts, *//' | sed 's/ \+tahr//')
fi

# we refresh the apt cache here, in case this is executed outside getpackages.sh
if [ "$2" != norefresh ]; then
    apt-get update
fi

# a small shortcut to simplify the logic later
if [ "${PHP_VERSION}" = 5.6 -a "${DEBIAN_VERSION}" = jessie ]; then
    PHP_VERSION=default
fi

if [ "${PHP_VERSION}" = default ]; then
    if [ "${DEBIAN_VERSION}" = jessie -o "${DEBIAN_VERSION}" = precise -o "${DEBIAN_VERSION}" = trusty ]; then
        PHPSUFFIX=5
    else
        PHPSUFFIX=
    fi
    if [ "${DEBIAN_VERSION}" = jessie ]; then
        EXTRA_PACKAGES=php5-xsl
        FORCE_OPT='--force-yes'
    else
        EXTRA_PACKAGES="php-mbstring php-xsl"
        FORCE_OPT=
    fi
    if [ "${DEBIAN_VERSION}" != jammy ]; then
        EXTRA_PACKAGES="${EXTRA_PACKAGES} php${PHPSUFFIX}-json"
    fi
    # @todo check for mbstring presence in php5 (jessie) packages
    DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated ${FORCE_OPT} \
        php${PHPSUFFIX} \
        php${PHPSUFFIX}-cli \
        php${PHPSUFFIX}-curl \
        php${PHPSUFFIX}-gd \
        php${PHPSUFFIX}-intl \
        php${PHPSUFFIX}-memcached \
        php${PHPSUFFIX}-mysql \
        php${PHPSUFFIX}-pgsql \
        php${PHPSUFFIX}-xdebug \
        ${EXTRA_PACKAGES}
else
    if apt-cache show "^php${PHP_VERSION}$" >/dev/null 2>/dev/null; then
        echo "PHP version found in existing apt repositories"
    elif update-alternatives --list php 2>/dev/null | fgrep -q "php${PHP_VERSION}"; then
        echo "PHP version found in update-alternatives"
    else
        # The correct php version is not available. Set up custom repos to get it
        echo "PHP version not found in existing apt repositories, setting up the ondrej one"

        # On GHA runners ubuntu version, many php versions are preinstalled. We remove them if found.
        # NB: this takes quite some time to execute. We should allow to execute it on demand
        #for PHP_CURRENT in $(dpkg -l | grep -E 'php.+-common' | awk '{print $2}'); do
        #    if [ "${PHP_CURRENT}" != "php${PHP_VERSION}-common" ]; then
        #        apt-get purge -y "${PHP_CURRENT}"
        #    fi
        #done

        if cat /etc/os-release | fgrep -q Ubuntu; then
            DEBIAN_FRONTEND=noninteractive apt-get install -y language-pack-en-base software-properties-common
        else
            DEBIAN_FRONTEND=noninteractive apt-get install -y gpg software-properties-common
        fi
        LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
        apt-get update
    fi

    EXTRA_PACKAGES=
    if [ "${PHP_VERSION}" != '8.0' -a "${PHP_VERSION}" != '8.1' -a "${PHP_VERSION}" != '8.2' ]; then
        EXTRA_PACKAGES="php${PHP_VERSION}-json"
    fi

    DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
        php${PHP_VERSION} \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-memcached \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-xml \
        ${EXTRA_PACKAGES}

    update-alternatives --set php /usr/bin/php${PHP_VERSION}
fi

# Left in in case we'd want to check we really got what we asked for...
#PHPVER=$(php -r 'echo implode(".",array_slice(explode(".",PHP_VERSION),0,2));' 2>/dev/null)

php -v

echo Done
