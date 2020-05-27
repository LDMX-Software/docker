
set -e

# make a working directory for the build
mkdir /cernroot && cd cernroot

# try to clone from the root-project github,
#   but only the branch of the version we care about
git clone -b v6-16-00 --single-branch https://github.com/root-project/root.git

# make a build directory and go into it
mkdir build && cd build

# configure the build
#   TODO investigate ways to turn off more things
cmake -DCMAKE_INSTALL_PREFIX=../install -Dgdml=ON -Dcxx17=ON ../root

# build and install
make install 

# cleanup
cd .. 
rm -rf root build
