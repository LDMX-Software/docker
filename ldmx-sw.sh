#!/bin/sh

###############################################################################
# Custom environment set-up for ldmx-sw
#   We want to make things easier for the user by automatically including
#   ldmx-sw in various environment variables.
#
#   Assumptions:
#     The installation location of ldmx-sw is defined in LDMX_SW_INSTALL
#     or it is located at LDMX_BASE/ldmx-sw/install.
###############################################################################

source /usr/local/bin/thisroot.sh
source /usr/local/bin/geant4.sh

# add ldmx-sw and ldmx-analysis installs to the various paths
if [ -z "${LDMX_SW_INSTALL}" ]; then
  export LDMX_SW_INSTALL=$LDMX_BASE/ldmx-sw/install
fi
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
