#!/bin/bash

set -e

################################################################################
# install-eigen.sh
#   Install Eigen headers into container
################################################################################

git clone https://gitlab.com/libeigen/eigen.git

mkdir eigen/build
cd eigen/build

cmake -DCMAKE_INSTALL_PREFIX=$Eigen_DIR ..

make install

cd .. #leave build
cd .. #leave eigen
rm -rf eigen
