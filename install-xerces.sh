
set -e

# make working directory
mkdir /xerces-c && cd xerces-c;

# download sources
wget https://downloads.apache.org//xerces/c/3/sources/xerces-c-3.2.3.tar.gz

# unpack the source
tar -zxvf xerces-c-3.2.3.tar.gz

# make and enter a build directory
mkdir build && cd build 

# configure the build
#   XercesC_DIR is set in ENV command
cmake -DCMAKE_INSTALL_PREFIX=$XercesC_DIR ../xerces-c-3.2.3 

# build and install
make install 

# cleanup
cd ..
rm -rf xerces-c-3.2.3 build
