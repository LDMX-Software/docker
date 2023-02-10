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

# Set-up computing environment
# WARNING: No check to see if there is anything in this directory
for init_script in ${__ldmx_env_script_d__}/*; do
  . $(realpath ${init_script})
done
unset init_script

# add ldmx-sw and ldmx-analysis installs to the various paths
if [ -z "${LDMX_SW_INSTALL}" ]; then
  export LDMX_SW_INSTALL=$LDMX_BASE/ldmx-sw/install
fi
export LD_LIBRARY_PATH=$LDMX_SW_INSTALL/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$LDMX_SW_INSTALL/python:$LDMX_SW_INSTALL/lib:$PYTHONPATH
export PATH=$LDMX_SW_INSTALL/bin:$PATH

#add what we need for GENIE 
export LD_LIBRARY_PATH=$GENIE/lib:/usr/local/pythia6:$LD_LIBRARY_PATH
export PATH=$GENIE/bin:$PATH

# add externals installed along side ldmx-sw
# WARNING: No check to see if there is anything in this directory
for _external_path in $LDMX_SW_INSTALL/external/*/lib
do
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$_external_path
done
unset _external_path


# helps simplify any cmake nonsense
export CMAKE_PREFIX_PATH=/usr/local/:$LDMX_SW_INSTALL

# puts a config/cache directory for matplotlib to use
export MPLCONFIGDIR=$LDMX_BASE/.config/matplotlib

# FLUKA Environment
# From env_FLUKA.sh
export PATH=$PATH:/usr/local/fluka/bin
export FLUKA_PATH=$(realpath $(dirname $(which fluka))/..)
if [ ! -d "$FLUKA_PATH" ]; then
   echo "!!! fluka not found. FLUKA_REPO=$FLUKA_PATH. Add your fluka_repo/bin to the PATH. !!!";
fi

export FLUKADATA=$FLUKA_PATH/data
if [ ! -d "$FLUKADATA" ]; then
   echo "!!! fluka data repo not found. FLUKADATA=$FLUKADATA. Add your fluka_repo/bin to the PATH. !!!";
fi

export FLUKA_LIB_DIR=$FLUKA_PATH/lib
if [ ! -d "$FLUKA_LIB_DIR" ]; then
   echo "!!! fluka lib repo not found. FLUKA_LIB_DIR=$FLUKA_LIB_DIR. Add your fluka_repo/bin to the PATH. !!!";
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FLUKA_LIB_DIR
# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"
