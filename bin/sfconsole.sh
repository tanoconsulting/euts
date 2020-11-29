#!/usr/bin/env bash

source $(dirname -- ${BASH_SOURCE[0]})/set-env-vars.sh

if [ -z "${CONSOLE_CMD}" ]; then
    if [ "${EZ_VERSION}" = "ezplatform3" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezplatform/bin/console
    elif [ "${EZ_VERSION}" = "ezplatform2" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezplatform/bin/console
    elif [ "${EZ_VERSION}" = "ezplatform" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezplatform/app/console
    elif [ "${EZ_VERSION}" = "ezpublish-community" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezpublish-community/ezpublish/console
    else
        printf "\n\e[31mERROR: unsupported eZ version: ${EZ_VERSION}\e[0m\n\n" >&2
        exit 1
    fi
fi

php $CONSOLE_CMD "$@"
