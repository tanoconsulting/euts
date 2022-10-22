#!/usr/bin/env bash

# Requires composer dependencies to have been set up already. And of course, eZ to have been set up as well

source "$(dirname -- "${BASH_SOURCE[0]}")/set-env-vars.sh"

php $CONSOLE_CMD "$@"
