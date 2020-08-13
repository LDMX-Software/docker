
set -e

# make a working directory for the build
mkdir cernroot && cd cernroot

# try to clone from the root-project github,
#   but only the branch of the version we care about
git clone -b ${ROOT} --single-branch https://github.com/root-project/root.git

# make a build directory and go into it
mkdir build && cd build

# Decide if we are going to do a minimal build
_yes_minimal=""
if [[ ${MINIMAL} == *"ON"* ]]
then
    _yes_minimal="-Dminimal=ON"
fi

_use_python=""
if [[ ${PyROOT_PyVersion} == *"3"* ]]
then
    _use_python="-DPYTHON_EXECUTABLE=$(which python3)"
fi

# configure the build
cmake \
    -Dxrootd=OFF \
    -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
    -DCMAKE_CXX_STANDARD=17 \
    ${_yes_minimal} ${_use_python} ../root

# build and install
cmake --build . --target install

# clean up before this layer is saved
cd ..
rm -rf build root
