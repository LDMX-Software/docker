#!/bin/bash 

set -e

###############################################################################
# Entry point for the ldmx development container
#   The basic idea is that we want to go into the container,
#   setup the ldmx-sw working environment, and then
#   run whatever executable the user wants.
#
#   A lot of executables require us to be in a specific location,
#   so the first argument is required to be a directory we can go to.
#   The rest of the arguments are passed to `eval` to be run as one command.
#
#   All of the aliases that are defined in the ldmx-env script will
#   have $(pwd) be the first argument to the entrypoint.
#   This means, before executing anything on the container,
#   we will go to the mounted location that the user is running from.
#
#   Assumptions:
#   - The installation location of ldmx-sw is defined in LDMX_SW_INSTALL
#     or it is located at LDMX_BASE/ldmx-sw/install.
#   - Any initialization scripts for external dependencies need to be
#     symlinked into the directory ${__ldmx_env_script_d__}
###############################################################################

if [[ -z $LDMX_CONTAINER_INSTALL ]]; then
  export LDMX_CONTAINER_INSTALL=${LDMX_BASE}/.container-install
fi
export LD_LIBRARY_PATH=${LDMX_CONTAINER_INSTALL}/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${LDMX_CONTAINER_INSTALL}/python:${PYTHONPATH}
export PATH=${LDMX_CONTAINER_INSTALL}/bin:${PATH}
export CMAKE_PREFIX_PATH=${LDMX_CONTAINER_INSTALL}

# puts a config/cache directory for matplotlib to use
export MPLCONFIGDIR=$LDMX_BASE/.config/matplotlib

# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"
