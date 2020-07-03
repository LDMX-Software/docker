
set -e

# make and enter working directory
mkdir geant4 && cd geant4

_geant4_remote="https://gitlab.cern.ch/geant4/geant4.git"
# get the single branch we need from github
if [[ "${GEANT4}" == *"LDMX"* ]]
then 
    # use ldmx geant4 fork
    _geant4_remote="https://github.com/LDMX-Software/geant4.git"
fi

git clone -b ${GEANT4} --single-branch ${_geant4_remote}

# make and enter build directory
mkdir build && cd build

# configure the build
cmake \
    -DGEANT4_INSTALL_DATA=ON \
    -DGEANT4_USE_GDML=ON \
    -DXERCESC_ROOT_DIR=$XercesC_DIR \
    -DGEANT4_USE_OPENGL_X11=ON \
    -DCMAKE_INSTALL_PREFIX=$G4DIR \
    ../geant4

# build and install
make install

# clean up before saving this layer
cd ..
rm -rf geant4 build
