#!/bin/bash

set -e

###############################################################################
# Entry point for the ldmx development container
#   The basic idea is that we want to go into the container,
#   setup the ldmx-sw working environment, and then
#   run whatever executable the user wants.
#
#   The setup of the working environment is done by copying or linking
#   environment scripts into /etc/profile.d/ inside the image when it is 
#   built. This forces those environment scripts to be sourced whenever
#   a new bash terminal is created (which will happen for this entry
#   script because of the sh-bang at the top).
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
#     All necessary environment set-up is completed automatically when
#     launching a new bash terminal.
###############################################################################

. /etc/profile

# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"
