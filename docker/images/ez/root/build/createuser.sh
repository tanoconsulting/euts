#!/bin/sh

# @todo grab the name of the user from cli options, maybe its GID & UID too

CONTAINER_USER=test

echo "Creating user '${CONTAINER_USER}'..."

addgroup --gid 1013 "${CONTAINER_USER}"
adduser --system --uid=1013 --gid=1013 --home "/home/${CONTAINER_USER}" --shell /bin/bash "${CONTAINER_USER}"
adduser "${CONTAINER_USER}" "${CONTAINER_USER}"

mkdir -p "/home/${CONTAINER_USER}/.ssh"
cp /etc/skel/.[!.]* "/home/${CONTAINER_USER}"

adduser "${CONTAINER_USER}" sudo
sed -i "$ a ${CONTAINER_USER}   ALL=\(ALL:ALL\) NOPASSWD: ALL" /etc/sudoers

chown -R "${CONTAINER_USER}:${CONTAINER_USER}" "/home/${CONTAINER_USER}"

echo Done
