#!/bin/sh

# @todo make the name of the user variable, as well as its GID & UID

addgroup --gid 1013 test
adduser --system --uid=1013 --gid=1013 --home /home/test --shell /bin/bash test
adduser test test

mkdir -p /home/test/.ssh
cp /etc/skel/.[!.]* /home/test

adduser test sudo
sed -i '$ a test   ALL=\(ALL:ALL\) NOPASSWD: ALL' /etc/sudoers

chown -R test:test /home/test
