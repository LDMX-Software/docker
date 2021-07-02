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
#   All of the aliases that are defined in the ldmx-setup script will
#   have $(pwd) be the first argument to the entrypoint.
#   This means, before executing anything on the container,
#   we will go to the mounted location that the user is running from.
#
#   Assumptions:
#       - LDMX_BASE/ldmx-sw/install is the installation location of ldmx-sw
###############################################################################

# add ldmx-sw and ldmx-analysis installs to the various paths
export LDMX_SW_INSTALL=$LDMX_BASE/ldmx-sw/install
export LD_LIBRARY_PATH=$LDMX_SW_INSTALL/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$LDMX_SW_INSTALL/python:$PYTHONPATH
export PATH=$LDMX_SW_INSTALL/bin:$PATH

# add externals installed along side ldmx-sw
# TODO this for loop might be very slow... might want to hard-code the externals path
for _external_path in $LDMX_SW_INSTALL/external/*/lib
do
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$_external_path
done

# helps simplify any cmake nonsense
export CMAKE_PREFIX_PATH=/usr/local/:$LDMX_SW_INSTALL

# puts a config/cache directory for matplotlib to use
export MPLCONFIGDIR=$LDMX_BASE/.config/matplotlib

# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"
