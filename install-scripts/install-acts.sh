#!/bin/bash

set -e

###############################################################################
# install-acts.sh
#   Install ACTS Common Tracking Software into the container
#
#   Assumptions
#       - Eigen installed at Eigen_DIR
#       - ACTS_DIR set to install path
#       - ROOTDIR set to ROOT install path
#       - G4DIR set to Geant4 install path
#       - XercesC_DIR set to xerces-c install path
#       - DD4hep_DIR set to DD4hep install path
###############################################################################

git clone https://github.com/acts-project/acts

export CMAKE_PREFIX_PATH=$XercesC_DIR:$ROOTDIR:$G4DIR:$DD4hep_DIR

cmake \
    -B acts/build                    \
    -S acts                          \
    -DACTS_BUILD_PLUGIN_DD4HEP=ON    \
    -DACTS_BUILD_EXAMPLES=OFF        \
    -DEigen3_DIR=$Eigen_DIR          \
    -DCMAKE_INSTALL_PREFIX=$ACTS_DIR 

cmake --build acts/build

rm -rf acts
