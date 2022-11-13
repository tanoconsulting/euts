#!/bin/sh

# Has to be run as admin

echo "Installing the required Node.js version..."

set -e

# install node
NODE_VERSION="$1"

if [ -z "${NODE_VERSION}" ]; then
    printf "\n\e[31mERROR:\e[0m unknown Node.js version to install\n\n" >&2
    exit 1
fi

DEBIAN_VERSION=$(lsb_release -s -c)

# we refresh the apt cache here, in case this is executed outside getpackages.sh
if [ "$2" != norefresh ]; then
    apt-get update
fi

if [ "${NODE_VERSION}" = default ]; then
    if [ "${DEBIAN_VERSION}" = jessie -o "${DEBIAN_VERSION}" = stretch ]; then
        echo "NB: not installing npm"
    else
        DEBIAN_FRONTEND=noninteractive apt-get install -y npm
    fi
else
    # @see https://github.com/nodesource/distributions/blob/master/README.md
    wget -q -O - "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash -
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs build-essential
fi

node --version

echo Done
