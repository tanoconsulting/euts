#!/usr/bin/env bash

# Uses env vars: DB_EZ_DATABASE, DB_EZ_PASSWORD, DB_EZ_USER, DB_HOST, DB_TYPE

# @todo support a -v option

set -e

DB_HOST_FLAG=

if [ -z "${DB_HOST}" ]; then
    DB_HOST="${DB_TYPE}"
fi

# @todo check that all required vars have a value

case "${DB_TYPE}" in
    mysql)
        #if [ "${TRAVIS}" != "true" ]; then
        #    DB_HOST_FLAG="-h ${DB_TYPE}"
        #fi
        mysql -h ${DB_HOST} -u${DB_EZ_USER} -p${DB_EZ_PASSWORD} "${DB_EZ_DATABASE}"
        ;;
    postgresql)

        #if [ "${TRAVIS}" != "true" ]; then
        #    DB_HOST_FLAG="-h ${DB_TYPE}"
        #fi
        # we rely on .pgpass for auth
        psql -h ${DB_HOST} -U ${DB_EZ_USER} -d ${DB_EZ_DATABASE}
        ;;
    *)
        printf "\n\e[31mERROR:\e[0m unknown db type '${DB_TYPE}'\n\n" >&2
        exit 1
esac
