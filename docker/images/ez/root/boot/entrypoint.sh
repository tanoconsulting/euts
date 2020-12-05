#!/bin/sh

echo "[$(date)] Bootstrapping the Test container..."

clean_up() {
    # Perform program exit housekeeping

    #echo "[$(date)] Stopping the Web server"
    #service apache2 stop

    #echo "[$(date)] Stopping Memcached"
    #service memcached stop

    #echo "[$(date)] Stopping Redis"
    #service redis-server stop

    #echo "[$(date)] Stopping Solr"
    #service solr stop

    if [ -f /var/run/bootstrap_ok ]; then
        rm /var/run/bootstrap_ok
    fi
    echo "[$(date)] Exiting"
    exit
}

# Allow any process to see if bootstrap finished by looking up this file
if [ -f /var/run/bootstrap_ok ]; then
    rm /var/run/bootstrap_ok
fi

# @todo in case this container was not built using our custom dockerfile but is a plain Debian one, we should run all
#       build actions at boot (and save the results in /var/build_ok)

# Fix UID & GID for user 'test'

echo "[$(date)] Fixing filesystem permissions..."

ORIGPASSWD=$(cat /etc/passwd | grep '^test:')
ORIG_UID=$(echo "$ORIGPASSWD" | cut -f3 -d:)
ORIG_GID=$(echo "$ORIGPASSWD" | cut -f4 -d:)
CONTAINER_USER_HOME=$(echo "$ORIGPASSWD" | cut -f6 -d:)
CONTAINER_USER_UID=${CONTAINER_USER_UID:=$ORIG_UID}
CONTAINER_USER_GID=${CONTAINER_USER_GID:=$ORIG_GID}

if [ "$CONTAINER_USER_UID" != "$ORIG_UID" -o "$CONTAINER_USER_GID" != "$ORIG_GID" ]; then
    groupmod -g "$CONTAINER_USER_GID" test
    usermod -u "$CONTAINER_USER_UID" -g "$CONTAINER_USER_GID" test
fi
if [ $(stat -c '%u' "${CONTAINER_USER_HOME}") != "${CONTAINER_USER_UID}" -o $(stat -c '%g' "${CONTAINER_USER_HOME}") != "${CONTAINER_USER_GID}" ]; then
    chown "${CONTAINER_USER_UID}":"${CONTAINER_USER_GID}" "${CONTAINER_USER_HOME}"
    chown -R "${CONTAINER_USER_UID}":"${CONTAINER_USER_GID}" "${CONTAINER_USER_HOME}"/.*
fi

if [ "${DB_TYPE}" = postgresql ]; then
    if [ -z "${DB_HOST}" ]; then
        DB_HOST=${DB_TYPE}
    fi
    echo "[$(date)] Setting up ~/.pgpass file..."
    echo "${DB_HOST}:5432:${DB_EZ_DATABASE}:${DB_EZ_USER}:${DB_EZ_PASSWORD}" > "${CONTAINER_USER_HOME}/.pgpass"
    echo "${DB_HOST}:5432:postgres:postgres:${DB_ROOT_PASSWORD}" >> "${CONTAINER_USER_HOME}/.pgpass"
    chown "${CONTAINER_USER_UID}":"${CONTAINER_USER_GID}" "${CONTAINER_USER_HOME}/.pgpass"
    chmod 600 "${CONTAINER_USER_HOME}/.pgpass"
fi

trap clean_up TERM

#echo "[$(date)] Starting Memcached..."
#service memcached start

#echo "[$(date)] Starting Redis..."
#service redis-server start

#echo "[$(date)] Starting Solr..."
#service solr start

#echo "[$(date)] Starting the Web server..."
#service apache2 start

if [ "${TESTSTACK_SETUP_APP_ON_BOOT}" != 'skip' ]; then

    /root/boot/symlinkvendors.sh

    # @todo we should force an app setup as well if current php version or env vars (bundles and other build-config vars
    #       such as php exts installed) are changed since we last did it => save the hash of the env vars in setup_ok
    #       instead of saving the exit code...

    if [ -f "${CONTAINER_USER_HOME}/setup_ok" ]; then
        RETCODE=$(cat ${CONTAINER_USER_HOME}/setup_ok)
        if [ "${RETCODE}" != '0' ]; then
            echo "[$(date)] Previous Application setup failed! Exit code: ${RETCODE}"
            TESTSTACK_SETUP_APP_ON_BOOT=force
        fi
    fi

    if [ "${TESTSTACK_SETUP_APP_ON_BOOT}" = 'force' -o ! -f ${CONTAINER_USER_HOME}/setup_ok ]; then
        echo "[$(date)] Setting up the Application..."
        su test -c "cd ${CONTAINER_USER_HOME}/bundle && ../teststack/bin/setup.sh; echo \$? > ${CONTAINER_USER_HOME}/setup_ok"
    fi
fi

echo "[$(date)] Bootstrap finished" | tee /var/run/bootstrap_ok

tail -f /dev/null &
child=$!
wait "$child"
