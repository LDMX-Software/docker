
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
    # build all possble components (and use python3)
    if [[ ${PyROOT_PyVersion} == *"3"* ]]
    then
        cmake \
            -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
            -DCMAKE_CXX_STANDARD=17 \
            -DPYTHON_EXECUTABLE=$(which python3) \
            ../root
    else
        cmake \
            -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
            -DCMAKE_CXX_STANDARD=17 \
            ../root
    fi
else
    # only build necessary components
    #   ldmx-sw uses Core, I/O, and Hists mainly
    #   root includes _a lot_ of components in its "necessary" list
    cmake \
        -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
        -DCMAKE_CXX_STANDARD=17 \
        -Dminimal=ON \
        ../root
fi

# build and install
make install 

# clean up before this layer is saved
cd ..
rm -rf build root
