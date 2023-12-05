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
###############################################################################

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


# puts a config/cache directory for matplotlib to use
export MPLCONFIGDIR=$LDMX_BASE/.config/matplotlib

# go to first argument
cd "$1"

# Developer option: If a custom geant4 install is to be used, source the
# environment script from that install
#
# Note: Use with care!
# The custom Geant4 install still needs to have been built with the same
# container environment
if [ -n "$LDMX_CUSTOM_GEANT4" ]; then
    source $LDMX_CUSTOM_GEANT4/bin/geant4.sh
    # Prioritize the cmake config in the Geant4 installation
    export CMAKE_PREFIX_PATH=$LDMX_CUSTOM_GEANT4/lib/cmake:$CMAKE_PREFIX_PATH
    if [ -z "$GEANT4_DATA_DIR" ]; then
        # Assume we are using 10.2.3
        export GEANT4_DATA_DIR=${G4DATADIR}
    fi
else
    # Default container location
    source /usr/local/bin/geant4.sh
    # helps simplify any cmake nonsense
    export CMAKE_PREFIX_PATH=/usr/local/:$LDMX_SW_INSTALL
fi
# execute the rest as a one-liner command
eval "${@:2}"
