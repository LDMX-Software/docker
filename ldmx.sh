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
#       - LDMX_BASE/ldmx-analysis/install is the installation location of ldmx-analysis
###############################################################################

## Bash environment script for use **within** the docker container
## Assuming the following environment variables are already defined by Dockerfile:
#   XercesC_DIR      - install of xerces-c
#   ONNX_DIR         - install of onnx runtime
#   ROOTDIR          - install of root
#   G4DIR            - install of Geant4
#   LDMX_BASE        - base directory where all ldmx-sw/ldmx-analysis code is

source $ROOTDIR/bin/thisroot.sh
source $G4DIR/bin/geant4.sh

# add ldmx-sw and ldmx-analysis installs to the various paths
export LD_LIBRARY_PATH=$ONNX_DIR/lib:$LDMX_BASE/ldmx-sw/install/lib:$LDMX_BASE/ldmx-analysis/install/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$LDMX_BASE/ldmx-sw/install/lib/python:$LDMX_BASE/ldmx-analysis/install/lib/python:$PYTHONPATH
export PATH=$LDMX_BASE/ldmx-sw/install/bin:$PATH

# helps simplify any cmake nonsense
export CMAKE_PREFIX_PATH=$XercesC_DIR:$ROOTDIR:$G4DIR:$ONNX_DIR:$LDMX_BASE/ldmx-sw/install

# go to first argument
cd "$1"

# execute the rest as a one-liner command
eval "${@:2}"