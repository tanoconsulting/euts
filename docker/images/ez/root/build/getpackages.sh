#!/bin/sh

# Installs required OS packages

# @todo make install of java, mysql/postgresql-client optional ?
# @todo move apache & varnish to dedicated, optional containers ?
# @todo move redis, memcached to dedicated, optional containers ? That would allow running a user-specified version...
# @todo install elasticache (or is it done by the eZ bundles?)
# @todo allow optional install of custom packages (is it better here or at boot time?)

echo "Installing software packages..."

# @todo use option parsing for a better command api
PHP_VERSION=$1
NODE_VERSION=$2

# `lsb-release` is not necessarily onboard. We parse /etc/os-release instead
DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION_CODENAME=' | sed 's/VERSION_CODENAME=//')
if [ -z "${DEBIAN_VERSION}" ]; then
    # Example strings:
    # VERSION="14.04.6 LTS, Trusty Tahr"
    # VERSION="8 (jessie)"
    DEBIAN_VERSION=$(cat /etc/os-release | grep 'VERSION=' | grep 'VERSION=' | sed 's/VERSION=//' | sed 's/"[0-9.]\+ *(\?//' | sed 's/)\?"//' | tr '[:upper:]' '[:lower:]' | sed 's/lts, *//' | sed 's/ \+tahr//')
fi

if [ "${DEBIAN_VERSION}" = jessie ]; then
    # Added on 2022/11/30: it seems there are expired keys at play now for jessie - we get error `KEYEXPIRED 1668891673`
    # Should we instead try to update the keys?
    # This could possibly help, but it does not seem to fix the error `KEYEXPIRED 1668891673`:
    #     for key in $(apt-key list | grep expired | awk '{print $2}' | sed 's/4096R\///' ); do apt-key adv --keyserver 'keyserver.ubuntu.com' --recv-keys "$key"; done
    # (note that it works in jessie but it requires previous installation of gpg in all later debian versions)
    # Other alternatives might be to:
    # - use `--allow-unauthenticated` instead of `--force-yes`. Possibly `-oAcquire::AllowInsecureRepositories=true`
    # - set `Acquire::Check-Valid-Until false;` in /etc/apt/apt.conf
    # - modify the sources.list files adding `deb [trusted=yes] etc...`
    FORCE_OPT='--force-yes'
else
    FORCE_OPT=
fi

if [ "${DEBIAN_VERSION}" = jessie -o -z "${DEBIAN_VERSION}" ]; then
    MYSQL_CLIENT=mysql-client
else
    MYSQL_CLIENT=default-mysql-client
fi

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y ${FORCE_OPT} \
    apache2 \
    default-jre-headless \
    "${MYSQL_CLIENT}" \
    git \
    memcached \
    postgresql-client \
    redis-server \
    sudo \
    unzip \
    varnish \
    wget \
    zip

echo Done

if [ -n "${NODE_VERSION}" ]; then
    # @todo what if we are not in the correct dir?
    ./getnode.sh "${NODE_VERSION}" norefresh
fi

if [ -n "${PHP_VERSION}" ]; then
    # @todo what if we are not in the correct dir?
    ./getphp.sh "${PHP_VERSION}" norefresh
fi
