#!/usr/bin/env bash

set -e

source "$(dirname -- "${BASH_SOURCE[0]}")/set-env-vars.sh"

PHPOPTS=
COVERAGE_OPT=
COVERAGE_FILE=
COVERAGE_UPLOAD=
TESTSUITE=Tests/phpunit
RESET=false
VERBOSITY=

while getopts ":c:vru:" opt
do
    case $opt in
        c)
            COVERAGE_FILE="${OPTARG}"
        ;;
        r)
            RESET=true
        ;;
        u)
            COVERAGE_UPLOAD="${OPTARG}"
            COVERAGE_FILE="coverage.clover"
            PHPOPTS="-d zend_extension=xdebug.so -d xdebug.mode=coverage"
        ;;
        v)
            VERBOSITY=-v
        ;;
        *)
            printf "\n\e[31mERROR:\e[0m unknown option '${opt}'\n\n" >&2
            exit 1
        ;;
    esac
done
shift $((OPTIND-1))

if [ "${RESET}" = true ]; then
    echo "Resetting the database..."
    "$(dirname -- "${BASH_SOURCE[0]}")/create-db.sh"
    echo "Purging eZ caches..."
    # Some manipulations make the SF console fail to run - that's why we prefer to clear the cache via file purge
    #"$(dirname -- "${BASH_SOURCE[0]}")/sfconsole.sh" ${VERBOSITY} cache:clear
    "$(dirname -- "${BASH_SOURCE[0]}")/cleanup.sh" ez-cache
    "$(dirname -- "${BASH_SOURCE[0]}")/cleanup.sh" ez-logs
    echo "Running the tests..."
fi

# Try to be smart parsing the cli params:
# - if there are only options and no args, do not unset TESTSUITE
# - if there are code coverage options, make sure we enable xdebug
if [ -n "$*" ]; then
    for ARG in "$@"
    do
        case "$ARG" in
        --coverage-*)
            PHPOPTS="-d zend_extension=xdebug.so -d xdebug.mode=coverage"
            ;;
        -*) ;;
        *)
            TESTSUITE=
            ;;
        esac
    done
fi

# Note: make sure we run the version of phpunit we installed, not the system one. See: https://github.com/sebastianbergmann/phpunit/issues/2014

if [ -n "${COVERAGE_FILE}" ]; then
    # @todo parse $COVERAGE_FILE, decide format to use for coverage based on file/dir name (not easy to do)
    COVERAGE_OPT="--coverage-clover=${COVERAGE_FILE}"
    PHPOPTS="-d zend_extension=xdebug.so -d xdebug.mode=coverage"
fi

php ${PHPOPTS} vendor/phpunit/phpunit/phpunit --stderr --colors ${VERBOSITY} ${COVERAGE_OPT} ${TESTSUITE} "$@"

if [ -n "${COVERAGE_UPLOAD}" ]; then
    if [ ! -f "${COVERAGE_FILE}" ]; then
        echo "Error: code coverage data not generated"
    else
        if [ "${COVERAGE_UPLOAD}" = codecov ]; then
            curl -Os https://uploader.codecov.io/latest/linux/codecov && chmod +x codecov && ./codecov -f "${COVERAGE_FILE}"
        elif [ "${COVERAGE_UPLOAD}" = scrutinizer ]; then
            curl -Os https://scrutinizer-ci.com/ocular.phar && php ocular.phar code-coverage:upload --format=php-clover "${COVERAGE_FILE}"
        else
            echo "Error: unsupported code coverage upload service: '${COVERAGE_UPLOAD}'"
        fi
    fi
fi
