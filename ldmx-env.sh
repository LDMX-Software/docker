
## Bash environment script for use **within** the docker container
## Assuming the following environment variables are already defined by Dockerfile:
#   LDMX_SW_INSTALL  - install of ldmx-sw
#   LDMX_SW_BUILD    - build of ldmx-sw
#   LDMX_ANA_INSTALL - install of ldmx-analysis
#   LDMX_ANA_BUILD   - build of ldmx-analysis
#   XercesC_DIR      - install of xerces-c
#   ONNX_DIR         - install of onnx runtime
#   ROOTDIR          - install of root
#   G4DIR            - install of Geant4
#   CODE             - base directory where all ldmx-sw/ldmx-analysis code is

source $ROOTDIR/bin/thisroot.sh
source $G4DIR/bin/geant4.sh

# make build and install directories just in case they don't exist yet
mkdir -p $LDMX_SW_INSTALL $LDMX_SW_BUILD $LDMX_ANA_INSTALL $LDMX_ANA_BUILD

# add ldmx-sw and ldmx-analysis installs to the various paths
#   assumes that both ldmx-sw and ldmx-analysis make python modules and libraries to be linked
#   only ldmx-sw makes executables
export LD_LIBRARY_PATH=$ONNX_DIR/lib:$LDMX_SW_INSTALL/lib:$LDMX_ANA_INSTALL/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$LDMX_SW_INSTALL/lib/python:$LDMX_ANA_INSTALL/lib/python:$PYTHONPATH
export PATH=$LDMX_SW_INSTALL/bin:$PATH

# go to ldmx-sw build and configure it
#   any arguments passed are assumed to be extra arguments for cmake (e.g. -DBUILD_TESTS=ON)
function ldmx-cmake() {
    cd $LDMX_SW_BUILD &&
    cmake -DCMAKE_INSTALL_PREFIX=$LDMX_SW_INSTALL -DXercesC_DIR=$XercesC_DIR -DONNXRUNTIME_ROOT=$ONNX_DIR "$@" $CODE/ldmx-sw
}

# go to ldmx-sw build and make it
#   any arguments passed are assumed to be extra arguments for make (e.g. install or -j4)
function ldmx-make() {
    cd $LDMX_SW_BUILD &&
    make "$@"
}

# go to ldmx-analysis build and configure it
#   any arguments passed are assumed to be extra arguments for cmake (e.g. -DBUILD_TESTS=ON)
function ldmx-ana-cmake() {
    cd $LDMX_ANA_BUILD &&
    cmake -DCMAKE_INSTALL_PREFIX=$LDMX_SW_INSTALL -DLDMX_INSTALL_PREFIX=$LDMX_SW_INTALL "$@" $CODE/ldmx-analysis
}

# go to ldmx-analysis build and make it
#   any arguments passed are assumed to be extra arguments for make (e.g. install or -j4)
function ldmx-ana-make() {
    cd $LDMX_ANA_BUILD &&
    make "$@"
}
