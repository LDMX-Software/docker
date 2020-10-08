
FROM ubuntu:18.04

# Geant4 and ROOT version arguments
# are formatted as the branch/tag to 
# pull from git
ARG GEANT4=geant4-10.5-release
ARG ROOT=v6-22-00-patches
ARG DD4HEP=v01-14-01
ARG EIGEN=3.3.8
ARG ACTS=v1.1.0
ARG MINIMAL=OFF

# XercesC and ONNX version arguments
# are formatted as they appear in
# the download link provided by those
# companies
ARG XERCESC=3.2.3

LABEL ubuntu.version="18.04" \
      root.version="${ROOT}" \
      minimal="${MINIMAL}" \
      geant4.version="${GEANT4}" \
      xerces.version="${XERCESC}" \
      dd4hep.version="${DD4HEP}" \
      eigen.version="${EIGEN}" \
      acts.version="${ACTS}"

MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

# First install any required dependencies from ubuntu repos
#   TODO clean up this dependency list
#
#   Dep              | Reason
#   wget             | install xerces and download Conditions tables
#   git              | download ROOT and Geant4 source
#   dpkg-dev         | ROOT external dependency for compression algorithms
#   python-dev       | ROOT interface with python2
#   python-pip       | install extra python2 packages
#   python-numpy     | extra python2 package numpy
#   python-tk        | matplotlib needs python-tk for some plotting stuff
#   python3-dev      | ROOT interface with python3 and ConfigurePython
#   python3-pip      | install extra python3 packages
#   python3-numpy    | extra python3 package numpy
#   python3-tk       | matplotlib needs python3-tk for some plotting stuff
#   make             | Build tool for compiling source code
#   g++-7            | Compiler with C++17 support
#   gcc-7            | Compiler with C++17 support
#   binutils         | ROOT external dependency for compression algorithms
#   libx11-dev       | ROOT external dependency for accessing screen
#   libxpm-dev       | ROOT external dependency for accessing screen
#   libxft-dev       | ROOT external dependency for accessing screen
#   libxext-dev      | ROOT and Geant4 external dependency for accessing screen
#   libxmu-dev       | ROOT and Geant4 external dependency for accessing screen
#   libgl1-mesa-dev  | ROOT and Geant4 external dependency for accessing screen
#   libboost-all-dev | Boost packages ldmx-sw uses
#   cmake            | Version 3.18 of cmake available from python3-pip
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        binutils \
        ca-certificates \
        davix-dev \
        dcap-dev \
        dpkg-dev \
        fonts-freefont-ttf \
        g++-7 \
        gcc-7 \
        git \
        libafterimage-dev \
        libboost-all-dev \
        libcfitsio-dev \
        libfcgi-dev \
        libfftw3-dev \
        libfreetype6-dev \
        libftgl-dev \
        libgfal2-dev \
        libgif-dev \
        libgl1-mesa-dev \
        libgl2ps-dev \
        libglew-dev \
        libglu-dev \
        libgraphviz-dev \
        libgsl-dev \
        libjpeg-dev \
        liblz4-dev \
        liblzma-dev \
        libmysqlclient-dev \
        libpcre++-dev \
        libpng-dev \
        libpq-dev \
        libpythia8-dev \
        libsqlite3-dev \
        libssl-dev \
        libtbb-dev \
        libtiff-dev \
        libx11-dev \
        libxext-dev \  
        libxft-dev \
        libxml2-dev \
        libxmu-dev \
        libxpm-dev \
        libxxhash-dev \
        libz-dev \
        libzstd-dev \
        locales \
        make \
        python-dev \
        python-pip \
        python-numpy \
        python-tk \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-tk \
        srm-ifce-dev \
        unixodbc-dev \
        wget \
    && rm -rf /var/lib/apt/lists/* &&\
    python3 -m pip install --upgrade --no-cache-dir cmake

# put installation scripts into temporary directory for later cleanup
COPY install-scripts/ /tmp/

###############################################################################
# Install CERN's ROOT into the container
#
# Assumptions
#  - ROOT defined as a  tag/branch of ROOT's git source tree
#  - MINIMAL defined as either ON or OFF
#  - ROOTDIR defined as target install location
###############################################################################
ENV ROOTDIR /deps/cernroot
RUN mkdir cernroot && cd cernroot &&\
    git clone -b ${ROOT} --single-branch https://github.com/root-project/root.git &&\
    mkdir build && cd build &&\
    cmake \
        -Dxrootd=OFF \
        -DCMAKE_CXX_STANDARD=17 \
        -Dminimal=${MINIMAL} \
        -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
        ../root &&\
    cmake --build . --target install &&\
    cd ../../ && rm -rf cernroot

################################################################################
# Install Xerces-C into container
#
# Assumptions
#  - XERCESC set to version matching an archived location of its source
#  - XercesC_DIR set to target installation location
################################################################################
ENV XercesC_DIR /deps/xerces-c
RUN mkdir xerces-c && cd xerces-c &&\
    wget http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${XERCESC}.tar.gz &&\
    tar -zxvf xerces-c-*.tar.gz &&\
    cd xerces* && mkdir build && cd build &&\
    cmake -DCMAKE_INSTALL_PREFIX=$XercesC_DIR .. &&\
    make install &&\
    cd ../../../ && rm -rf xerces-c

###############################################################################
# Install Geant4 into the container
#
# Assumptions
#  - GEANT4 defined to be a branch/tag of geant4 or LDMX's fork of geant4
#  - XercesC_DIR set to install of Xerces-C
#  - G4DIR set to path where Geant4 should be installed
###############################################################################
ENV G4DIR /deps/geant4
RUN _geant4_remote="https://gitlab.cern.ch/geant4/geant4.git" &&\
    if echo "${GEANT4}" | grep -q "LDMX"; then \
        _geant4_remote="https://github.com/LDMX-Software/geant4.git" \
    fi &&\
    git clone -b ${GEANT4} --single-branch ${_geant4_remote} &&\
    cd geant4 && mkdir build && cd build &&\
    cmake \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
        -DXERCESC_ROOT_DIR=$XercesC_DIR \
        -DCMAKE_INSTALL_PREFIX=$G4DIR \
        .. &&\
    make install &&\
    cd ../../ && rm -rf geant4

###############################################################################
# Installing DD4hep within the container build
#
# Assumptions
#  - ROOT installed at $ROOTDIR
#  - Geant4 installed at $G4DIR
#  - $DD4hep_DIR set to install path
###############################################################################
ENV DD4hep_DIR /deps/dd4hep
RUN cd ${ROOTDIR}/bin && . thisroot.sh &&\
    cd ${G4DIR}/bin && . geant4.sh &&\
    cd / &&\
    git clone -b ${DD4HEP} --single-branch https://github.com/AIDASoft/DD4hep.git &&\
    mkdir DD4hep/build && cd DD4hep/build &&\
    CMAKE_PREFIX_PATH=$XercesC_DIR:$ROOTDIR:$G4DIR cmake \
        -DCMAKE_INSTALL_PREFIX=$DD4hep_DIR \
        -DBoost_NO_BOOST_CMAKE=ON \
        -DBUILD_TESTING=OFF \
        -DDD4HEP_USE_GEANT4=ON \
        -DDD4HEP_USE_XSERCESC=ON \
        -DDD4HEP_BUILD_PACKAGES="DDRec DDDetectors DDCond DDAlign DDCAD DDDigi DDG4" \
        .. &&\
    make install
    cd ../../ && rm -rf DD4hep

################################################################################
# Install Eigen headers into container
#
# Assumptions
#  - Eigen_DIR set to install path
################################################################################
ENV Eigen_DIR /deps/eigen
RUN git clone -b ${EIGEN} --single-branch https://gitlab.com/libeigen/eigen.git &&\
    mkdir eigen/build && cd eigen/build &&\
    cmake -DCMAKE_INSTALL_PREFIX=$Eigen_DIR .. &&\
    make install &&\
    cd ../../ && rm -rf eigen

###############################################################################
# Install ACTS Common Tracking Software into the container
#
# Assumptions
#  - Eigen installed at Eigen_DIR
#  - ACTS_DIR set to install path
#  - ROOTDIR set to ROOT install path
#  - G4DIR set to Geant4 install path
#  - XercesC_DIR set to xerces-c install path
#  - DD4hep_DIR set to DD4hep install path
###############################################################################
ENV ACTS_DIR /deps/acts
RUN git clone -b ${ACTS} --single-branch https://github.com/acts-project/acts &&\
    CMAKE_PREFIX_PATH=$XercesC_DIR:$ROOTDIR:$G4DIR:$DD4hep_DIR cmake \
        -B acts/build \
        -S acts \
        -DACTS_BUILD_PLUGIN_DD4HEP=ON \
        -DACTS_BUILD_EXAMPLES=OFF \
        -DEigen3_DIR=$Eigen_DIR \
        -DCMAKE_INSTALL_PREFIX=$ACTS_DIR &&\
    cmake --build acts/build &&\
    rm -rf acts

# clean up source and build files from apt-get
RUN rm -rf /tmp/* && apt-get clean && apt-get autoremove 

#copy over necessary running script which sets up environment
COPY ./ldmx.sh /home/
RUN chmod 755 /home/ldmx.sh

# extra python packages
#   we run these python packages through the running script
#   because we want them to 'know' the container run-time environment
RUN ./home/ldmx.sh . python3 -m pip install --upgrade --no-cache-dir \
        uproot \
        numpy \
        matplotlib \
        xgboost \
        sklearn &&\
    ./home/ldmx.sh . python -m pip install --upgrade --no-cache-dir \
        uproot \
        numpy \
        matplotlib \
        xgboost \
        sklearn

# add any ssl certificates to the container to trust
COPY ./certs/ /usr/local/share/ca-certificates
RUN update-ca-certificates

#run environment setup when docker container is launched and decide what to do from there
#   will require the environment variable LDMX_BASE defined
ENTRYPOINT ["/home/ldmx.sh"]
