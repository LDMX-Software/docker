
FROM ubuntu:18.04 

LABEL ldmxsw.version="2.0.0" \
      root.version="6.16.00" \
      geant4.version="10.2.3.v0.3" \
      ubuntu.version="18.04" \
      xerces.version="3.2.3"

MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

# First install any required dependencies from ubuntu repos
RUN apt-get update && \
    apt-get install -y wget git cmake dpkg-dev python-dev make g++-7 gcc-7 binutils libx11-dev libxpm-dev libxft-dev libxext-dev libboost-all-dev libxmu-dev libgl1-mesa-dev && \
    apt-get update

# Let's build and install ROOT
# It's ugly to have all these commands in one RUN, but it helps keep the docker image smaller
RUN mkdir cernroot && \
    cd cernroot && \
    git clone -b v6-16-00 --single-branch https://github.com/root-project/root.git && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=../install -Dgdml=ON -Dcxx17=ON ../root && \
    make install && \
    cd .. && \
    rm -rf root build

# Build and Install Xerces-C
ENV XercesC_DIR /xerces-c/install
RUN mkdir xerces-c && \
    cd xerces-c && \
    wget https://downloads.apache.org//xerces/c/3/sources/xerces-c-3.2.3.tar.gz && \
    tar -zxvf xerces-c-3.2.3.tar.gz && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=$XercesC_DIR ../xerces-c-3.2.3 && \
    make install && \
    cd .. && \
    rm -rf xerces-c-3.2.3 build

# Build and Install Geant4
RUN mkdir geant4 && \
    cd geant4 && \
    git clone -b LDMX.10.2.3_v0.3 --single-branch https://github.com/LDMXAnalysis/geant4.git && \
    mkdir build && \
    cd build && \
    cmake -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$XercesC_DIR -DGEANT4_USE_OPENGL_X11=ON -DCMAKE_INSTALL_PREFIX=../install ../geant4 && \
    make install && \
    cd .. && \
    rm -rf geant4 build

RUN apt-get clean && \
    apt-get autoremove

# Make a non-super user and become them
RUN useradd --user-group --system --create-home --no-log-init --shell /bin/bash ldmx-user
USER ldmx-user
WORKDIR /home/ldmx-user

# Add setup environment to their automatically loaded bashrc
RUN echo "source /cernroot/install/bin/thisroot.sh" >> .bashrc && \
    echo "source /geant4/install/bin/geant4.sh"     >> .bashrc && \
    echo "export XercesC_DIR=/xerces-c/install"     >> .bashrc
