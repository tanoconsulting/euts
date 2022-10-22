#!/usr/bin/env bash

# Housekeeping - remove cache, logs, etc.
#
# Uses env vars: EZ_VERSION

set -e

source "$(dirname -- "${BASH_SOURCE[0]}")/set-env-vars.sh"

if [ "${EZ_VERSION}" = "ezplatform33" ]; then
    if [ -z "${VAR_DIR}" ]; then
        VAR_DIR=vendor/ibexa/oss-skeleton/var
    fi
elif [ "${EZ_VERSION}" = "ezplatform3" ]; then
    if [ -z "${VAR_DIR}" ]; then
        VAR_DIR=vendor/ezsystems/ezplatform/var
    fi
elif [ "${EZ_VERSION}" = "ezplatform2" ]; then
    if [ -z "${VAR_DIR}" ]; then
        VAR_DIR=vendor/ezsystems/ezplatform/var
    fi
elif [ "${EZ_VERSION}" = "ezplatform" ]; then
    if [ -z "${VAR_DIR}" ]; then
        VAR_DIR=vendor/ezsystems/ezplatform/var
    fi
elif [ "${EZ_VERSION}" = "ezpublish-community" ]; then
    if [ -z "${VAR_DIR}" ]; then
        VAR_DIR=vendor/ezsystems/ezpublish-community/ezpublish
    fi
else
    printf "\n\e[31mERROR:\e[0m unsupported eZ version '${EZ_VERSION}'\n\n" >&2
    exit 1
fi

if [ -z "${LEGACY_VAR_DIR}" ]; then
    if [ -d vendor/ezsystems/ezpublish-legacy/var ]; then
        LEGACY_VAR_DIR=vendor/ezsystems/ezpublish-legacy/var
    fi
fi

case "${1}" in
    ez-cache | cache)
        rm -rf ${VAR_DIR}/cache/*
        if [ -n "${LEGACY_VAR_DIR}" ]; then
            rm -rf ${LEGACY_VAR_DIR}/cache/*
            rm -rf ${LEGACY_VAR_DIR}/*/cache/*
        fi
    ;;
    ez-logs | logs)
        rm -rf ${VAR_DIR}/logs/*
        if [ -n "${LEGACY_VAR_DIR}" ]; then
            rm -rf ${LEGACY_VAR_DIR}/log/*
            rm -rf ${LEGACY_VAR_DIR}/*/log/*
        fi
    ;;
    vendors | vendor)
        rm -rf vendor/*
    ;;
    *)
        printf "\n\e[31mERROR:\e[0m unknown cleanup target '${1}'\n\n" >&2
        exit 1
esac
