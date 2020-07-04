
set -e

# make a working directory for the build
mkdir cernroot && cd cernroot

# try to clone from the root-project github,
#   but only the branch of the version we care about
git clone -b ${ROOT} --single-branch https://github.com/root-project/root.git

# make a build directory and go into it
mkdir build && cd build

# configure the build
if [[ ${MINIMAL} == *"OFF"* ]]
then
    cmake \
        -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
        -Dgdml=ON \
        -DCMAKE_CXX_STANDARD=17 \
        ../root
else
    cmake \
        -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
        -Dminimal=ON \
        -Dgdml=ON \
        -Dpyroot=ON \
        -DCMAKE_CXX_STANDARD=17 \
        ../root
fi

# build and install
make install 

# clean up before this layer is saved
cd ..
rm -rf build root
