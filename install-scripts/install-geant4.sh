
set -e

# make and enter working directory
mkdir geant4 && cd geant4

# get the single branch we need from github
git clone -b LDMX.10.2.3_v0.3 --single-branch https://github.com/LDMXAnalysis/geant4.git

# make and enter build directory
mkdir build && cd build

# configure the build
cmake -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$XercesC_DIR -DGEANT4_USE_OPENGL_X11=ON -DCMAKE_INSTALL_PREFIX=../install ../geant4

# build and install
make install

# clean up
cd .. 
rm -rf geant4 build
