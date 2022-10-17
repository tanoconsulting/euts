#!/usr/bin/env bash

# Set up DB configuration files.
# Runs both on CI workers and in the DB Docker container (in which case it runs, as root, before the db service is started)
#
# Uses env vars: DB_TYPE, EZ_VERSION (optional), MYSQL_VERSION (optional), GITHUB_ACTION, TRAVIS, TRAVIS_PHP_VERSION, DOCKER

set -e

echo "Setting up DB configuration..."

# On some Travis base image, the DB is stopped by default
# @todo fix: we should rely on the os version instead, or, even better, check for the service status
#       These two IFs probably presume that a specific os/mysql version is in use on Travis for php 5.6...
if [ "${TRAVIS_PHP_VERSION}" = "5.6" ]; then
    if [ "${DB_TYPE}" = mysql ]; then
        sudo systemctl start mysql
    fi
fi

# On GHA runners, the DB is stopped by default
if [ -n "${GITHUB_ACTION}" ]; then
    # @todo we should also check the os version (would the teststack work at all on macos?)
    case "${DB_TYPE}" in
        mysql)
            sudo systemctl start mysql.service
            ;;
        postgresql)
            sudo systemctl start postgresql.service
            ;;
        *)
            printf "\n\e[31mERROR:\e[0m unknown db type '${DB_TYPE}'\n\n" >&2
            exit 1
    esac
fi

if [ "${DB_TYPE}" = "mysql" ]; then

    # on Travis/GHA, if someone has loaded a .env file, the variables MYSQL_VERSION/POSTGRESQL_VERSION might be set and
    # not match what is on the VM. We disregard it in that case
    if [ -n "${TRAVIS}" -o -n "${GITHUB_ACTION}" -o -z "${MYSQL_VERSION}" ]; then
        # @todo check if this works on all mysql versions we support: debian, ubuntu, mariadb, mysql
        # ex: mysql  Ver 14.14 Distrib 5.6.51, for Linux (x86_64) using  EditLine wrapper
        # ex: mysql  Ver 8.0.30-0ubuntu0.20.04.2 for Linux on x86_64 ((Ubuntu))
        MYSQL_VERSION=$(mysql -V | sed -E 's/mysql +Ver +//' | sed -E 's/[0-9.]+ +Distrib +//' | sed -E 's/,? +for.+//' | sed -E 's/-.+//')
    fi
    if [ -z "${MYSQL_VERSION}" ]; then
        printf "\n\e[31mERROR:\e[0m can not retrieve MYSQL_VERSION\n" >&2
        exit 1
    fi

    if [ -f /etc/mysql/my.cnf ]; then
        CONFIG_FILE=/etc/mysql/my.cnf
    elif [ -f /etc/my.cnf ]; then
        CONFIG_FILE=/etc/my.cnf
    else
        printf "\n\e[31mERROR:\e[0m can not find mysql server config file\n" >&2
        exit 1
    fi

    # MySQL 5.7 defaults to strict mode, which is not good with ezpublish community kernel 2014.11.8
    # @todo what about MySQL 8.0 ? And MariaDB ?
    if [[ "${MYSQL_VERSION}" == 5.7* ]]; then
        if [ -z "${EZ_VERSION}" ]; then
            source "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")/set-env-vars.sh"
        fi
        if [ "${EZ_VERSION}" = "ezpublish-community" ]; then
            # We want to only remove STRICT_TRANS_TABLES, really
            if [ -n "${TRAVIS}" -o -n "${GITHUB_ACTION}" ]; then
                #mysql -u${DB_USER} ${DB_PWD} -e "SHOW VARIABLES LIKE 'sql_mode';"
                echo -e "\n[server]\nsql-mode='ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'\n" | sudo tee -a "$CONFIG_FILE"
                sudo service mysql restart
            elif [ "${DOCKER}" = true ]; then
               if grep -q 'sql-mode=' "$CONFIG_FILE"; then
                   sed -r -i -e "s|^#*sql-mode=.*$|sql-mode='ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'|g" "$CONFIG_FILE"
               else
                   echo -e "\n[server]\nsql-mode='ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'\n" >> -a "$CONFIG_FILE"
               fi
            fi
        fi
    fi

    # MySQL 8.0 defaults to an auth plugin which is not compatible with php < 7.4
    if [[ "${MYSQL_VERSION}" == 8.0* ]]; then
        if [ -n "${TRAVIS}" -o -n "${GITHUB_ACTION}" ]; then
            echo -e "\n[server]\ndefault_authentication_plugin=mysql_native_password\n" | sudo tee -a "$CONFIG_FILE"
            sudo service mysql restart
        elif [ "${DOCKER}" = true ]; then
           if grep -q 'default_authentication_plugin=' "$CONFIG_FILE"; then
               sed -r -i -e "s|^#*default_authentication_plugin=.*$|default_authentication_plugin=mysql_native_password|g" "$CONFIG_FILE"
           else
               echo -e "\n[server]\ndefault_authentication_plugin=mysql_native_password\n" >> "$CONFIG_FILE"
           fi
        fi
    fi
fi

echo Done
