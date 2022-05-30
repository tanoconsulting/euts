#!/usr/bin/env bash

# Set up DB configuration files
#
# Uses env vars: DB_TYPE, EZ_VERSION, GITHUB_ACTION, TRAVIS, TRAVIS_PHP_VERSION

set -e

echo "Setting up DB configuration..."

if [ "${TRAVIS_PHP_VERSION}" = "5.6" ]; then
    # @todo should we not rely on the os version instead? or, even better, check for the service status?
    if [ "${DB_TYPE}" = mysql ]; then
        sudo systemctl start mysql
    fi
fi

# On GHA runners, the DB is stopped by default
if [ -n "${GITHUB_ACTION}" ]; then
    # @todo we should also check the os version
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

# MySQL 5.7 defaults to strict mode, which is not good with ezpublish community kernel 2014.11.8
# @todo besides testing for Travis/GHA, check as well for MYSQL_VERSION
if [ "${EZ_VERSION}" = "ezpublish-community" -a "${DB_TYPE}" = "mysql" ]; then
    if [ "${TRAVIS}" = "true" -o -n "${GITHUB_ACTION}" ]; then
        # We want to only remove STRICT_TRANS_TABLES, really
        #mysql -u${DB_USER} ${DB_PWD} -e "SHOW VARIABLES LIKE 'sql_mode';"
        echo -e "\n[server]\nsql-mode='ONLY_FULL_GROUP_BY,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'\n" | sudo tee -a /etc/mysql/my.cnf
        sudo service mysql restart
    fi
fi

echo Done
