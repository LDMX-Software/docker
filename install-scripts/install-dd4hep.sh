#!/bin/bash

set -e

###############################################################################
# install-dd4hep.sh
#   Installing DD4hep within the container build
#
#   Assumptions
#       - ROOT installed at $ROOTDIR
#       - Geant4 installed at $G4DIR
#       - $DD4hep_DIR set to install path
###############################################################################

source $ROOTDIR/bin/thisroot.sh #adds root directories to necessary xxxPATH shell variables
source $G4DIR/bin/geant4.sh #adds geant4 and xerces-c directories to necessary xxxPATH shell variables

# helps simplify any cmake nonsense
export CMAKE_PREFIX_PATH=$XercesC_DIR:$ROOTDIR:$G4DIR

git clone https://github.com/AIDASoft/DD4hep.git

# remove DDEve from list of compiled modules
sed -in 's/DDEve\ UtilityApps//g' DD4hep/CMakeLists.txt

mkdir DD4hep/build
cd DD4hep/build

cmake \
    -DCMAKE_INSTALL_PREFIX=$DD4hep_DIR \
    -DDD4HEP_USE_GEANT4=ON             \
    -DDD4HEP_USE_XERCESC=ON            \
    -DBoost_NO_BOOST_CMAKE=ON          \
    -DBUILD_TESTING=OFF                \
    ..

make install

cd .. #out of build
cd .. #out of DD4hep
rm -rf DD4hep
