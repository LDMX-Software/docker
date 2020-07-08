
set -e

# make working directory
mkdir xerces-c && cd xerces-c;

# download sources
wget http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${XERCESC}.tar.gz

# unpack the source
tar -zxvf xerces-c-*.tar.gz
rm xerces-c-*.tar.gz

# make and enter a build directory
cd xerces* && mkdir build && cd build 

# configure the build
#   XercesC_DIR is set in ENV command
cmake -DCMAKE_INSTALL_PREFIX=$XercesC_DIR ..

# build and install
make install 

# clean up before saving this layer
cd ../../
rm -rf xerces-c*
