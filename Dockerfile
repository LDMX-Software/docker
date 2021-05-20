
FROM ubuntu:18.04
LABEL ubuntu.version="18.04"
MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

# The minimal argument is an attempt to decrease the size of the container
# by only including necessary packages/libraries for running ldmx-sw.
#   It is still in development
#
# The options are: "ON" or "OFF"
ARG MINIMAL=ON
LABEL minimal="${MINIMAL}"

# First install any required dependencies from ubuntu repos
#   TODO clean up this dependency list
# Ongoing documentation for this list is in docs/ubuntu-packages.md
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

###############################################################################
# Install CERN's ROOT into the container
#
# Assumptions
#  - ROOT defined as a  tag/branch of ROOT's git source tree
#  - MINIMAL defined as either ON or OFF
#  - ROOTSYS defined as target install location
###############################################################################
ARG ROOT=v6-18-04
LABEL root.version="${ROOT}"
ENV ROOTSYS /deps/cernroot
RUN mkdir cernroot &&\
    git clone -b ${ROOT} --single-branch https://github.com/root-project/root.git cernroot/root &&\
    mkdir /cernroot/build &&\
    cmake \
        -Dxrootd=OFF \
        -DCMAKE_CXX_STANDARD=17 \
        -Dminimal=${MINIMAL} \
        -Dopengl=ON \
        -DCMAKE_INSTALL_PREFIX=$ROOTSYS \
        -B /cernroot/build \
        -S /cernroot/root \
        &&\
    cmake \
        --build /cernroot/build \
        --target install \
    &&\
    rm -rf cernroot

################################################################################
# Install Xerces-C into container
#
# Assumptions
#  - XERCESC set to version matching an archived location of its source
#  - XercesC_DIR set to target installation location
################################################################################
ENV XercesC_DIR /deps/xerces-c
ARG XERCESC=3.2.3
LABEL xercesc.version="${XERCESC}"
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
ARG GEANT4=LDMX.10.2.3_v0.4
LABEL geant4.version="${GEANT4}"
RUN _geant4_remote="https://gitlab.cern.ch/geant4/geant4.git" &&\
    if echo "${GEANT4}" | grep -q "LDMX"; then \
        _geant4_remote="https://github.com/LDMX-Software/geant4.git"; \
    fi &&\
    git clone -b ${GEANT4} --single-branch ${_geant4_remote} &&\
    cd geant4 &&\
    cmake \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
        -DGEANT4_USE_OPENGL_X11=ON \
        -DXERCESC_ROOT_DIR=$XercesC_DIR \
        -DCMAKE_INSTALL_PREFIX=$G4DIR \
        -B build \
        -S . \
        &&\
    cmake \
        --build build \
        --target install \
    &&\
    cd .. && rm -rf geant4

###############################################################################
# Extra python packages for analysis
#   
# Assumptions
#  - ROOTSYS is installation location of root
###############################################################################
#RUN export PYTHONPATH=$ROOTSYS/lib &&\
#    export CLING_STANDARD_PCH=none &&\
#    export LD_LIBRARY_PATH=$XercesC_DIR/lib:$ROOTSYS/lib:$G4DIR/lib:$LD_LIBRARY_PATH &&\
#    python3 -m pip install --upgrade --no-cache-dir \
#        Cython \
#        uproot \
#        numpy \
#        matplotlib \
#        xgboost \
#        sklearn &&\
#    python -m pip install --upgrade --no-cache-dir \
#        Cython \
#        uproot \
#        numpy \
#        matplotlib \
#        xgboost \
#        sklearn

# clean up source and build files from apt-get
RUN rm -rf /tmp/* && apt-get clean && apt-get autoremove 

#copy over necessary running script which sets up environment
COPY ./ldmx.sh /home/
RUN chmod 755 /home/ldmx.sh

# add any ssl certificates to the container to trust
COPY ./certs/ /usr/local/share/ca-certificates
RUN update-ca-certificates

# install ldmx-sw
#COPY ./ldmx-sw /ldmx-sw-code
#RUN mkdir /ldmx-sw-code/build &&\
#    ./home/ldmx.sh /ldmx-sw-code/build cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. &&\
#    ./home/ldmx.sh /ldmx-sw-code/build make install &&\
#    mv /ldmx-sw-code/scripts/docker_entrypoint.sh /home/entrypoint.sh &&\
#    rm -rf ldmx-sw-code

RUN chmod 755 /home/entrypoint.sh
ENTRYPOINT ["/home/entrypoint.sh"]
