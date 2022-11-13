#!/bin/sh

# Installs required OS packages

# @todo make install of java, mysql/postgresql-client optional ?
# @todo move apache & varnish to dedicated, optional containers ?
# @todo move redis, memcached to dedicated, optional containers ? This allows running a user-specified version...
# @todo install elasticache (or is it done by the eZ bundles?)
# @todo allow optional install of custom packages (is it better here or at boot time?)

echo "Installing software packages..."

# @todo use option parsing for a better command api
PHP_VERSION=$1
NODE_VERSION=$2

# `lsb-release` is not yet onboard...
DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION_CODENAME=' | sed 's/VERSION_CODENAME=//')
if [ -z "${DEBIAN_VERSION}" ]; then
    DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION=' | sed 's/VERSION=//' | sed 's/"[0-9] *(//' | sed 's/)"//')
fi

if [ "${DEBIAN_VERSION}" = jessie -o -z "${DEBIAN_VERSION}" ]; then
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apache2 \
        default-jre-headless \
        mysql-client \
        git \
        lsb-release \
        memcached \
        postgresql-client \
        redis-server \
        sudo \
        unzip \
        varnish \
        wget \
        zip
else
    # stretch, buster, bullseye, plus all ubuntu versions?
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apache2 \
        default-jre-headless \
        default-mysql-client \
        git \
        lsb-release \
        memcached \
        postgresql-client \
        redis-server \
        sudo \
        unzip \
        varnish \
        wget \
        zip
fi

echo Done

if [ -n "${NODE_VERSION}" ]; then
    # @todo what if we are not in the correct dir?
    ./getnode.sh "${NODE_VERSION}" norefresh
fi

if [ -n "${PHP_VERSION}" ]; then
    # @todo what if we are not in the correct dir?
    ./getphp.sh "${PHP_VERSION}" norefresh
fi
