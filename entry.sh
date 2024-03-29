#!/bin/bash 

set -e

source /etc/ldmx-env-init.sh

# puts a config/cache directory for matplotlib to use
# does /not/ need to be in the ldmx-env-init.sh script since denv-based
# interactions with the image define LDMX_BASE as HOME for us anyways
export MPLCONFIGDIR=$LDMX_BASE/.config/matplotlib

# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"
