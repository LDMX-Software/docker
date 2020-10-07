#!/bin/bash

set -e

################################################################################
# install-xerces.sh
#   Install Xerces-C into container
#
#   Assumptions
#       - XERCESC set to version matching an archived location of its source
#       - XercesC_DIR set to target installation location
################################################################################

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
cd .. #leave build
cd .. #leave xerces source dir
cd .. #leave working dir
rm -rf xerces-c
