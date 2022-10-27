#!/bin/sh

# @todo grab the workspace dir from cli options

CONTAINER_USER=test
ORIGPASSWD=$(cat /etc/passwd | grep "^${CONTAINER_USER}:")
CONTAINER_USER_HOME=$(echo "$ORIGPASSWD" | cut -f6 -d:)
WORKSPACE_DIR="${CONTAINER_USER_HOME}/workspace"

# WAS: we hash the name of the vendor folder based on packages to install. This allows quick swaps of vendors
#if [ -z "${TESTSTACK_VENDOR_DIR}" ]; then
#    P_V=$(php -r 'echo PHP_VERSION;')
#    # @todo should we add to the hash calculation a hash of the contents of the original composer.json ?
#    # @todo we should add to the hash calculation a hash of the installed php extensions
#    # @todo to avoid generating uselessly different variations, we should as well sort EZ_PACKAGES
#    TESTSTACK_VENDOR_DIR=vendor_$(echo "${P_V} ${EZ_PACKAGES}" | md5sum | awk  '{print $1}')
#fi
TESTSTACK_VENDOR_DIR="vendor_${COMPOSE_PROJECT_NAME}"

# @todo we assume that /${WORKSPACE_DIR}/vendor is never a file...

if [ -d "${WORKSPACE_DIR}/vendor" -a ! -L "${WORKSPACE_DIR}/vendor" ]; then
    printf "\n\e[33mWARNING:\e[0m vendor folder is not a symlink\n\n"
fi

if [ -L "${WORKSPACE_DIR}/vendor" -o ! -d "${WORKSPACE_DIR}/vendor" ]; then
    echo "[$(date)] Setting up vendor folder as symlink to ${TESTSTACK_VENDOR_DIR}..."

    if [ ! -d "${WORKSPACE_DIR}/${TESTSTACK_VENDOR_DIR}" ]; then
        mkdir "${WORKSPACE_DIR}/${TESTSTACK_VENDOR_DIR}"
    fi
    chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "${WORKSPACE_DIR}/${TESTSTACK_VENDOR_DIR}"

    # The double-symlink craze makes it possible to have the 'vendor' symlink on the host disk (mounted as volume),
    # while allowing each container to have it point to a different target 'real' vendor dir which is also on the
    # host disk

    # @todo what if local_vendor exists and is a dir or file ?
    if [ -L "${CONTAINER_USER_HOME}/local_vendor" ]; then
        rm "${CONTAINER_USER_HOME}/local_vendor"
    fi
    ln -s "${WORKSPACE_DIR}/${TESTSTACK_VENDOR_DIR}" "${CONTAINER_USER_HOME}/local_vendor"

    if [ -L "${WORKSPACE_DIR}/vendor" ]; then
        TARGET=$(readlink -f "${WORKSPACE_DIR}/vendor")
        if [ "${TARGET}" != "${WORKSPACE_DIR}/${TESTSTACK_VENDOR_DIR}" ]; then
            echo "[$(date)] Fixing vendor folder symlink from ${TARGET} to ${WORKSPACE_DIR}/${TESTSTACK_VENDOR_DIR}..."
            rm "${WORKSPACE_DIR}/vendor"
            ln -s "${CONTAINER_USER_HOME}/local_vendor" "${WORKSPACE_DIR}/vendor"
            if [ -f "${CONTAINER_USER_HOME}/setup_ok" ]; then rm "${CONTAINER_USER_HOME}/setup_ok"; fi
        fi
    else
        echo "[$(date)] Creating vendor folder symlink to ${TESTSTACK_VENDOR_DIR}..."
        ln -s "${CONTAINER_USER_HOME}/local_vendor" "${WORKSPACE_DIR}/vendor"
        if [ -f "${CONTAINER_USER_HOME}/setup_ok" ]; then rm "${CONTAINER_USER_HOME}/setup_ok"; fi
    fi
fi
