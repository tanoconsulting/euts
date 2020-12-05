#!/bin/sh

ORIGPASSWD=$(cat /etc/passwd | grep '^test:')
CONTAINER_USER_HOME=$(echo "$ORIGPASSWD" | cut -f6 -d:)

# WAS: we hash the name of the vendor folder based on packages to install. This allows quick swaps of vendors
#if [ -z "${TESTSTACK_VENDOR_DIR}" ]; then
#    P_V=$(php -r 'echo PHP_VERSION;')
#    # @todo should we add to the hash calculation a hash of the contents of the original composer.json ?
#    # @todo we should add to the hash calculation a hash of the installed php extensions
#    # @todo to avoid generating uselessly different variations, we should as well sort EZ_PACKAGES
#    TESTSTACK_VENDOR_DIR=vendor_$(echo "${P_V} ${EZ_PACKAGES}" | md5sum | awk  '{print $1}')
#fi
TESTSTACK_VENDOR_DIR="vendor_${TESTSTACK_PROJECT_NAME}"

# @todo we assume that /home/test/bundle/vendor is never a file...

if [ -d "${CONTAINER_USER_HOME}/bundle/vendor" -a ! -L "${CONTAINER_USER_HOME}/bundle/vendor" ]; then
    printf "\n\e[33mWARNING:\e[0m vendor folder is not a symlink\n\n"
fi

if [ -L "${CONTAINER_USER_HOME}/bundle/vendor" -o ! -d "${CONTAINER_USER_HOME}/bundle/vendor" ]; then
    echo "[$(date)] Setting up vendor folder as symlink to ${TESTSTACK_VENDOR_DIR}..."

    if [ ! -d "${CONTAINER_USER_HOME}/bundle/${TESTSTACK_VENDOR_DIR}" ]; then
        mkdir "${CONTAINER_USER_HOME}/bundle/${TESTSTACK_VENDOR_DIR}"
    fi
    chown -R test:test "${CONTAINER_USER_HOME}/bundle/${TESTSTACK_VENDOR_DIR}"

    # The double-symlink craze makes it possible to have the 'vendor' symlink on the host disk (mounted as volume),
    # while allowing each container to have it point to a different target 'real' vendor dir which is also on the
    # host disk

    # @todo what if local_vendor exists and is a dir or file ?
    if [ -L "${CONTAINER_USER_HOME}/local_vendor" ]; then
        rm "${CONTAINER_USER_HOME}/local_vendor"
    fi
    ln -s "${CONTAINER_USER_HOME}/bundle/${TESTSTACK_VENDOR_DIR}" "${CONTAINER_USER_HOME}/local_vendor"

    if [ -L "${CONTAINER_USER_HOME}/bundle/vendor" ]; then
        TARGET=$(readlink -f "${CONTAINER_USER_HOME}/bundle/vendor")
        if [ "${TARGET}" != "${CONTAINER_USER_HOME}/bundle/${TESTSTACK_VENDOR_DIR}" ]; then
            echo "[$(date)] Fixing vendor folder symlink from ${TARGET} to ${CONTAINER_USER_HOME}/bundle/${TESTSTACK_VENDOR_DIR}..."
            rm "${CONTAINER_USER_HOME}/bundle/vendor"
            ln -s "${CONTAINER_USER_HOME}/local_vendor" "${CONTAINER_USER_HOME}/bundle/vendor"
            if [ -f "${CONTAINER_USER_HOME}/setup_ok" ]; then rm "${CONTAINER_USER_HOME}/setup_ok"; fi
        fi
    else
        echo "[$(date)] Creating vendor folder symlink to ${TESTSTACK_VENDOR_DIR}..."
        ln -s "${CONTAINER_USER_HOME}/local_vendor" "${CONTAINER_USER_HOME}/bundle/vendor"
        if [ -f "${CONTAINER_USER_HOME}/setup_ok" ]; then rm "${CONTAINER_USER_HOME}/setup_ok"; fi
    fi
fi
