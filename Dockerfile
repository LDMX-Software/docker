
FROM ubuntu:18.04
LABEL ubuntu.version="18.04"
MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

ARG NPROC=1

# First install any required dependencies from ubuntu repos
# Ongoing documentation for this list is in docs/ubuntu-packages.md
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        autoconf \
        automake \
        binutils \
        ca-certificates \
        fonts-freefont-ttf \
        g++-7 \
        gcc-7 \
        gdb \
        gfortran \
        libafterimage-dev \
        libasan4-dbg \
        libfftw3-dev \
        libfreetype6-dev \
        libftgl-dev \
        libgif-dev \
        libgl1-mesa-dev \
        libgl2ps-dev \
        libglew-dev \
        libglu-dev \
        libgsl-dev \
        libjpeg-dev \
        liblz4-dev \
        liblzma-dev \
        libpcre++-dev \
        libpng-dev \
        libssl-dev \
        libtool \
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
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-tk \
        srm-ifce-dev \
        wget \
    && rm -rf /var/lib/apt/lists/* &&\
    apt-get autoremove --purge &&\
    apt-get clean all &&\
    python3 -m pip install --upgrade pip &&\
    python3 -m pip install --upgrade --no-cache-dir cmake

###############################################################################
# Source-Code Downloading Method
#   mkdir src && ${__wget} <url-to-tar.gz-source-archive> | ${__untar}
#
#   Adapted from acts-project/machines
###############################################################################
ENV __wget wget -q -O -
ENV __untar tar -xz --strip-components=1 --directory src
ENV __prefix /usr/local
ENV __ldmx_env_script_d__ /etc/ldmx-container-env.d

# All init scripts in this directory will be run upon entry into container
RUN mkdir ${__ldmx_env_script_d__}

###############################################################################
# Boost
###############################################################################
LABEL boost.version="1.76.0"
RUN mkdir src &&\
    ${__wget} https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz |\
      ${__untar} &&\
    cd src &&\
    # Configure Boost.Python to look for the Python version we have.
    sed -i 's/using python ;/using python : 3.6 ;/' libs/python/build/Jamfile &&\
    ./bootstrap.sh &&\
    ./b2 -j$NPROC install &&\
    cd .. && rm -rf src

################################################################################
# Xerces-C 
################################################################################
LABEL xercesc.version="3.2.3"
RUN mkdir src &&\
    ${__wget} http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.3.tar.gz |\
      ${__untar} &&\
    cmake -B src/build -S src -DCMAKE_INSTALL_PREFIX=${__prefix} &&\
    cmake --build src/build --target install -j$NPROC &&\
    rm -rf src

###############################################################################
# PYTHIA6
#
# Needed for GENIE. Needs to be linked with ROOT.
#
# Looks complicated? Tell me about it.
# Core of what's done follows from here: https://root-forum.cern.ch/t/root-with-pythia6-and-pythia8/19211
# (1) Download pythia6 build tarball from ROOT. Known to lead to a build that can work with ROOT.
# (2) Download the latest Pythia6 (6.4.2.8) from Pythia. Yes, it's still ancient.
# (3) Declare extern some definitions that need to be extern via sed. Compiler/linker warns. Hard-won solution.
# (4) Build with C and FORTRAN the various pieces.
# (5) Put everything in a directory in the install area, and cleanup.
#
# (Ideally GENIE works with Pythia8? But not sure that works yet despite the adverts that it does.)
# 
###############################################################################
LABEL pythia.version="6.428"
RUN mkdir src && \
    ${__wget} https://root.cern.ch/download/pythia6.tar.gz |\
     ${__untar} &&\
    wget --no-check-certificate https://pythia.org/download/pythia6/pythia6428.f &&\
    mv pythia6428.f src/pythia6428.f && rm -rf src/pythia6416.f &&\
    cd src/ &&\
    sed -i 's/int py/extern int py/g' pythia6_common_address.c && \
    sed -i 's/extern int pyuppr/int pyuppr/g' pythia6_common_address.c && \
    sed -i 's/char py/extern char py/g' pythia6_common_address.c && \
    echo 'void MAIN__() {}' >main.c && \
    gcc -c -m64 -fPIC -shared main.c -lgfortran && \
    gcc -c -m64 -fPIC -shared pythia6_common_address.c -lgfortran && \
    gfortran -c -m64 -fPIC -shared pythia*.f && \
    gfortran -c -m64 -fPIC -shared -fno-second-underscore tpythia6_called_from_cc.F && \
    gfortran -m64 -shared -Wl,-soname,libPythia6.so -o libPythia6.so main.o  pythia*.o tpythia*.o &&\
    mkdir -p ${__prefix}/pythia6 && cp -r * ${__prefix}/pythia6/ &&\
    cd ../ && rm -rf src

###############################################################################
# CERN's ROOT
###############################################################################
LABEL root.version="6.22.08"
RUN mkdir src &&\
    ${__wget} https://root.cern/download/root_v6.22.08.source.tar.gz |\
     ${__untar} &&\
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -Dgminimal=ON \
      -Dasimage=ON \
      -Dgdml=ON \
      -Dopengl=ON \
      -Dpyroot=ON \
      -Dgnuinstall=ON \
      -Dxrootd=OFF \
      -Dgsl_shared=ON \ 
      -Dmathmore=ON \   
      -Dpythia6=ON \    
      -DPYTHIA6_LIBRARY=${__prefix}/pythia6/libPythia6.so \
      -B build \
      -S src \
    && cmake --build build --target install -j$NPROC &&\
    ln -s /usr/local/bin/thisroot.sh ${__ldmx_env_script_d__}/thisroot.sh &&\
    rm -rf build src

###############################################################################
# Geant4
#
# Assumptions
#  - GEANT4 defined to be a release of geant4 or LDMX's fork of geant4
###############################################################################
ENV GEANT4=LDMX.10.2.3_v0.4
LABEL geant4.version="${GEANT4}"
RUN __owner="geant4" &&\
    echo "${GEANT4}" | grep -q "LDMX" && __owner="LDMX-Software" &&\
    mkdir src &&\
    ${__wget} https://github.com/${__owner}/geant4/archive/${GEANT4}.tar.gz | ${__untar} &&\
    cmake \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
        -DGEANT4_USE_OPENGL_X11=ON \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src \
        &&\
    cmake --build src/build --target install -j$NPROC &&\
    ln -s /usr/local/bin/geant4.sh ${__ldmx_env_script_d__}/geant4.sh &&\ 
    rm -rf src 

###############################################################################
# Extra python packages for analysis
###############################################################################
ENV PYTHONPATH /usr/local/lib
ENV CLING_STANDARD_PCH none
RUN python3 -m pip install --upgrade --no-cache-dir \
        Cython \
        uproot \
        numpy \
        matplotlib \
        xgboost \
        sklearn

################################################################################
# Install Eigen headers into container
#
# Assumptions
#  - EIGEN set to release name from GitLab repository
################################################################################
ENV EIGEN=3.4.0
LABEL eigen.version="${EIGEN}"
RUN mkdir src &&\
    ${__wget} https://gitlab.com/libeigen/eigen/-/archive/${EIGEN}/eigen-${EIGEN}.tar.gz |\
      ${__untar} &&\
    cmake \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src \
    &&\
    cmake \
        --build src/build \
        --target install \
        -j$NPROC \
    &&\
    rm -rf src 

###############################################################################
# Installing DD4hep within the container build
#
# Assumptions
#  - Dependencies installed to ${__prefix}
#  - DD4HEP set to release name from GitHub repository
###############################################################################
ENV DD4HEP=v01-18
LABEL dd4hep.version="${DD4HEP}"
RUN mkdir src &&\
    ${__wget} https://github.com/AIDASoft/DD4hep/archive/refs/tags/${DD4HEP}.tar.gz |\
      ${__untar} &&\
    export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/root &&\
    cmake \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -DBUILD_TESTING=OFF \
        -B src/build \
        -S src \
    &&\
    cmake \
        --build src/build \
        --target install \
	-j$NPROC \
    &&\
    ln -s ${__prefix}/bin/thisdd4hep.sh ${__ldmx_env_script_d__}/thisdd4hep.sh &&\
    rm -r src

###############################################################################
# LHAPDF
#
# Needed for GENIE
#
###############################################################################
LABEL lhapdf.version="6.5.2"
ENV PYTHON_VERSION=3
RUN mkdir src &&\
    ${__wget} https://lhapdf.hepforge.org/downloads/?f=LHAPDF-6.5.2.tar.gz |\
     ${__untar} &&\
    cd src &&\
    ./configure --prefix=${__prefix} &&\
    make -j$NPROC install &&\
    cd ../ &&\
    rm -rf src

###############################################################################
# Installing log4cpp
#
# Needed for GENIE
#
###############################################################################
RUN mkdir src &&\
    ${__wget} https://sourceforge.net/projects/log4cpp/files/latest/download |\
    ${__untar} &&\
    cd src/log4cpp &&\
    ./autogen.sh &&\
    ./configure &&\
    make check &&\
    make install -j$NPROC &&\
    cd ../.. &&\
    rm -r src

###############################################################################
# GENIE
#
# Needed for ... GENIE :)
#
###############################################################################
LABEL genie.version=3.02.00
ENV GENIE_VERSION=3_02_00
ENV GENIE_REWEIGHT_VERSION=1_02_00

ENV GENIE=/usr/local/GENIE/Generator

RUN mkdir -p /usr/local/root &&\
    ln -s /usr/local/lib/root /usr/local/root/lib &&\
    export ROOTSYS=/usr/local/root &&\
    mkdir -p /usr/local/GENIE/Generator &&\
    cd /usr/local/GENIE &&\
    wget -q -O - https://github.com/GENIE-MC/Generator/archive/refs/tags/R-${GENIE_VERSION}.tar.gz |\
    tar -xz -C Generator --strip-components 1 &&\
    cd Generator &&\
    export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/root &&\
    ./configure --enable-lhapdf6 --disable-lhapdf5 \
                --enable-gfortran --with-gfortran-lib=/usr/x86_64-linux-gnu/ \
                --disable-pythia8 --with-pythia6-lib=${__prefix}/pythia6 \
                --enable-test && \
    make -j$NPROC && \
    make -j$NPROC install

####################################################################################
# Move these to the end so if the inputs change, no need to completely rebuild...
####################################################################################

# add any ssl certificates to the container to trust
COPY ./certs/ /usr/local/share/ca-certificates
RUN update-ca-certificates

#run environment setup when docker container is launched and decide what to do from there
#   will require the environment variable LDMX_BASE defined
COPY ./entry.sh /etc/
RUN chmod 755 /etc/entry.sh
ENTRYPOINT ["/etc/entry.sh"]
