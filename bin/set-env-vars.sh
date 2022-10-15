#!/usr/bin/env bash

# Set up env vars (if not already set):
# - KERNEL_CLASS, KERNEL_DIR (used by phpunit)
# Requires composer dependencies to have been set up already, if EZ_VERSION is not set.
#
# Uses env vars: EZ_VERSION, `composer` command if EZ_VERSION not set
#
# To be executed using 'source'

# @todo also set up APP_ENV, SYMFONY_ENV (defaulting to 'behat')

if [ -n "${COMPOSE_PROJECT_NAME}" ]; then
    export COMPOSER="composer_${COMPOSE_PROJECT_NAME}.json"
fi

# Figure out EZ_VERSION if required
# @todo can we manage to do it without running composer? See how we do it in db-config.sh...
if [ -z "${EZ_VERSION}" ]; then
    # @todo check if COMPOSER env var is set and not matching COMPOSE_PROJECT_NAME and abort if it is
    if [ -n "${COMPOSE_PROJECT_NAME}" -a -z "${COMPOSER}" ]; then
        export COMPOSER="composer_${COMPOSE_PROJECT_NAME}.json"
    fi
    EZ_VERSION=$(composer show | grep ezsystems/ezpublish-kernel || true)
    if [ -n "${EZ_VERSION}" ]; then
        if [[ "${EZ_VERSION}" == *" v7."* ]]; then
            export EZ_VERSION=ezplatform2
        else
            if [[ "${EZ_VERSION}" == *" v6."* ]]; then
                export EZ_VERSION=ezplatform
            else
                export EZ_VERSION=ezpublish-community
            fi
        fi
    else
        EZ_VERSION=$(composer show | grep ezsystems/ezplatform-kernel || true)
        if [ -n "${EZ_VERSION}" ]; then
            # @todo what about ezplatform 4?
            export EZ_VERSION=ezplatform3
        fi
    fi
    # No need to abort here if  EZ_VERSION is null: we do it later
fi

# @todo Figure out EZ_BUNDLES from EZ_PACKAGES if the former is not set
#if [ -z "${EZ_BUNDLES}" -a -n "${EZ_PACKAGES}" ]; then
#fi

if [ "${EZ_VERSION}" = "ezplatform3" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        export KERNEL_CLASS=App\\Kernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        export KERNEL_DIR=vendor/ezsystems/ezplatform/src
    fi
elif [ "${EZ_VERSION}" = "ezplatform2" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        export KERNEL_CLASS=AppKernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        export KERNEL_DIR=vendor/ezsystems/ezplatform/app
    fi
elif [ "${EZ_VERSION}" = "ezplatform" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        export KERNEL_CLASS=AppKernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        export KERNEL_DIR=vendor/ezsystems/ezplatform/app
    fi
elif [ "${EZ_VERSION}" = "ezpublish-community" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        export KERNEL_CLASS=EzPublishKernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        export KERNEL_DIR=vendor/ezsystems/ezpublish-community/ezpublish
    fi
else
    printf "\n\e[31mERROR:\e[0m unsupported eZ version '${EZ_VERSION}'\n\n" >&2
    exit 1
fi
