#!/usr/bin/env bash

# Set up env vars (if not already set):
# - KERNEL_CLASS, KERNEL_DIR (used by phpunit)
# Requires composer dependencies to have been set up already, if EZ_VERSION is not set.
#
# Uses env vars: EZ_VERSION, `composer` command if EZ_VERSION not set
#
# To be executed using 'source'

# @todo also set up APP_ENV, SYMFONY_ENV (defaulting to 'behat')

# @todo what if `which` is not installed?
if which composer >/dev/null 2>/dev/null; then
    if [ -n "${COMPOSE_PROJECT_NAME}" ]; then
        COMPOSER="composer_${COMPOSE_PROJECT_NAME}.json"
    fi

    # Figure out EZ_VERSION if required
    if [ -z "${EZ_VERSION}" ]; then
        # @todo make this work when current dir != project root dir (do we need and env var for finding it?)
        EZ_VERSION=$(composer show | grep ezsystems/ezpublish-kernel || true)
        if [ -n "${EZ_VERSION}" ]; then
            if [[ "${EZ_VERSION}" == *" v7."* ]]; then
                EZ_VERSION=ezplatform2
            else
                if [[ "${EZ_VERSION}" == *" v6."* ]]; then
                    EZ_VERSION=ezplatform
                else
                    EZ_VERSION=ezpublish-community
                fi
            fi
        else
            EZ_VERSION=$(composer show | grep ezsystems/ezplatform-kernel || true)
            if [ -n "${EZ_VERSION}" ]; then
                EZ_VERSION=$(composer show | grep ibexa/oss || true)
                if [ -z "${EZ_VERSION}" ]; then
                    EZ_VERSION=ezplatform3
                else
                    EZ_VERSION=ezplatform33
                fi
            else
                # @todo detect ezplatform 4
                :
            fi
        fi
        # No need to abort here if  EZ_VERSION is null: we do it later
    fi
else
    # Figure out EZ_VERSION if required, when composer is not available
    if [ -z "${EZ_VERSION}" ]; then
        # we are running most likely in a db Container, with no php available. We rely on EZ_PACKAGES get the info
        # @todo q: if EZ_COMPOSER_LOCK is set, EZ_PACKAGES is most likely empty. Is it more reliable to scan composer.lock
        #       in that case? Also, what if eZP was in composer.json instead of EZ_PACKAGES env var?
        if [[ "${EZ_PACKAGES}" == *ezsystems/ezpublish-community* ]]; then
            EZ_VERSION=ezpublish-community
        elif [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:1.'* ]] || [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:~1.'* ]] || [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:^1.'* ]]; then
            EZ_VERSION=ezplatform
        elif [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:2.'* ]] || [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:~2.'* ]] || [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:^2.'* ]]; then
            EZ_VERSION=ezplatform2
        elif [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:3.'* ]] || [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:~3.'* ]] || [[ "${EZ_PACKAGES}" == *'ezsystems/ezplatform:^3.'* ]]; then
            EZ_VERSION=ezplatform3
        elif [[ "${EZ_PACKAGES}" == *'ibexa/oss-skeleton:3.3'* ]] || [[ "${EZ_PACKAGES}" == *'ibexa/oss-skeleton:~3.3'* ]] || [[ "${EZ_PACKAGES}" == *'ibexa/oss-skeleton:^3.3'* ]]; then
            EZ_VERSION=ezplatform33
        fi
    fi
fi

# @todo Figure out EZ_BUNDLES from EZ_PACKAGES if the former is not set
#if [ -z "${EZ_BUNDLES}" -a -n "${EZ_PACKAGES}" ]; then
#fi

if [ "${EZ_VERSION}" = "ezplatform33" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        KERNEL_CLASS=App\\Kernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        KERNEL_DIR=vendor/ibexa/oss-skeleton/src
    fi
    if [ -z "${CONSOLE_CMD}" ]; then
        CONSOLE_CMD=vendor/ibexa/oss-skeleton/bin/console
    fi
elif [ "${EZ_VERSION}" = "ezplatform3" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        KERNEL_CLASS=App\\Kernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        KERNEL_DIR=vendor/ezsystems/ezplatform/src
    fi
    if [ -z "${CONSOLE_CMD}" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezplatform/bin/console
    fi
elif [ "${EZ_VERSION}" = "ezplatform2" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        KERNEL_CLASS=AppKernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        KERNEL_DIR=vendor/ezsystems/ezplatform/app
    fi
    if [ -z "${CONSOLE_CMD}" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezplatform/bin/console
    fi
elif [ "${EZ_VERSION}" = "ezplatform" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        KERNEL_CLASS=AppKernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        KERNEL_DIR=vendor/ezsystems/ezplatform/app
    fi
    if [ -z "${CONSOLE_CMD}" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezplatform/app/console
    fi
elif [ "${EZ_VERSION}" = "ezpublish-community" ]; then
    if [ -z "${KERNEL_CLASS}" ]; then
        KERNEL_CLASS=EzPublishKernel
    fi
    if [ -z "${KERNEL_DIR}" ]; then
        KERNEL_DIR=vendor/ezsystems/ezpublish-community/ezpublish
    fi
    if [ -z "${CONSOLE_CMD}" ]; then
        CONSOLE_CMD=vendor/ezsystems/ezpublish-community/ezpublish/console
    fi
else
    printf "\n\e[31mERROR:\e[0m unsupported eZ version '${EZ_VERSION}'\n\n" >&2
    exit 1
fi
