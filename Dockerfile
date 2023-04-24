
FROM ubuntu:22.04
LABEL ubuntu.version="22.04"
MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

ARG NPROC=1

# First install any required dependencies from ubuntu repos
# Ongoing documentation for this list is in docs/ubuntu-packages.md
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        apt-utils \
        autoconf \
        automake \
        bc \
        binutils \
        ca-certificates \
        clang-format \
        cmake \
        curl \
        dialog \
        diffutils \
        findutils \
        fish \
        fonts-freefont-ttf \
        g++ \
        gcc \
        gdb \
        gfortran \
        gnupg2 \
        less \
        libafterimage-dev \
        libasan8 \
        libboost-all-dev \
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
        liblog4cpp5-dev \
        liblz4-dev \
        liblzma-dev \
        libnss-myhostname \
        libpcre++-dev \
        libpng-dev \
        libssl-dev \
        libtool \
        libvte-2.9[0-9]-common \
        libvte-common \
        libx11-dev \
        libxext-dev \  
        libxft-dev \
        libxml2-dev \
        libxmu-dev \
        libxpm-dev \
        libz-dev \
        libzstd-dev \
        lsof \
        locales \
        make \
        ncurses-base \
        passwd \
        pinentry-curses \
        procps \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-tk \
        sudo \
        srm-ifce-dev \
        time \
        util-linux \
        wget \
        zsh \
    && rm -rf /var/lib/apt/lists/* &&\
    apt-get autoremove --purge &&\
    apt-get clean all

###############################################################################
# Source-Code Downloading Method
#   mkdir src && ${__wget} <url-to-tar.gz-source-archive> | ${__untar}
#
#   Adapted from acts-project/machines
###############################################################################
ENV __wget wget -q -O -
ENV __untar_to="tar -xz --strip-components=1 --directory"
ENV __untar="${__untar_to} src"
ENV __prefix /usr/local

# this directory is where folks should "install" code compiled with the container
#    i.e. folks should mount a local install directory to /externals so that the
#    container can see those files and those files can be found from these env vars
ENV EXTERNAL_INSTALL_DIR=/externals
ENV PATH="${EXTERNAL_INSTALL_DIR}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${EXTERNAL_INSTALL_DIR}/lib"
ENV PYTHONPATH="${EXTERNAL_INSTALL_DIR}/lib:${EXTERNAL_INSTALL_DIR}/python:${EXTERNAL_INSTALL_DIR}/lib/python"
ENV CMAKE_PREFIX_PATH="${EXTERNAL_INSTALL_DIR}:${__prefix}" 

################################################################################
# Xerces-C 
#   Used by Geant4 to parse GDML
################################################################################
LABEL xercesc.version="3.2.4"
RUN mkdir src &&\
    ${__wget} http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.4.tar.gz |\
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
# Core of what's done follows from here: 
#   https://root-forum.cern.ch/t/root-with-pythia6-and-pythia8/19211
# (1) Download pythia6 build tarball from ROOT. Known to lead to a build that can work with ROOT.
# (2) Download the latest Pythia6 (6.4.2.8) from Pythia. Yes, it's still ancient.
# (3) Declare extern some definitions that need to be extern via sed. 
#     Compiler/linker warns. Hard-won solution.
# (4) Build with C and FORTRAN the various pieces.
# (5) Put everything in a directory in the install area, and cleanup.
#
# (Ideally GENIE works with Pythia8? But not sure that works yet despite the adverts that it does.)
# 
###############################################################################
LABEL pythia.version="6.428"
RUN mkdir src && \
    ${__wget} https://root.cern.ch/download/pythia6.tar.gz | ${__untar} &&\
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
    cd ../ && rm -rf src &&\
    echo "${__prefix}/pythia6/" > /etc/ld.so.conf.d/pythia6.conf

###############################################################################
# CERN's ROOT
#  Needed for GENIE and serialization within the Framework
#
# We have a very specific configuration of the ROOT build system
# - Use C++17 so that ROOT doesn't re-define C++17 STL classes in its headers
#   We want to use C++17 in Framework and ROOT's redefinitions prevent that.
# - Use gnuinstall=ON and CMAKE_INSTALL_LIBDIR=lib to make ROOT be a system install
# - Start with a minimal build (gminimal) and then enable things from there.
# - Need asimage and opengl built for the ROOT GUIs to be functional.
# - Want pyroot to support some PyROOT-based analyses
# - Turn off xrootd since its build fails for some reason (and we don't need it)
# - gsl_shared, mathmore, and pytia6 are all used by GENIE
#
# After building and installing, we write a ld conf file to include ROOT's
# libraries in the linker cache, then rebuild the linker cache so that
# downstream libraries in this Dockerfile can link to ROOT easily.
#
# We promote the environment variables defined in thisroot.sh to this
# Dockerfile so that thisroot.sh doesn't need to be sourced.
###############################################################################
LABEL root.version="6.22.08"
RUN mkdir src &&\
    ${__wget} https://root.cern/download/root_v6.22.08.source.tar.gz |\
     ${__untar} &&\
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_INSTALL_PREFIX=${__prefix} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -Dgnuinstall=ON \
      -Dgminimal=ON \
      -Dasimage=ON \
      -Dgdml=ON \
      -Dopengl=ON \
      -Dpyroot=ON \
      -Dxrootd=OFF \
      -Dgsl_shared=ON \ 
      -Dmathmore=ON \   
      -Dpythia6=ON \    
      -DPYTHIA6_LIBRARY=${__prefix}/pythia6/libPythia6.so \
      -B build \
      -S src \
    && cmake --build build --target install -j$NPROC &&\
    rm -rf build src &&\
    ldconfig
ENV ROOTSYS=${__prefix}
ENV PYTHONPATH=${ROOTSYS}/lib:${PYTHONPATH}
ENV JUPYTER_PATH=${ROOTSYS}/etc/notebook:${JUPYTER_PATH}
ENV JUPYTER_CONFIG_DIR=${ROOTSYS}/etc/notebook:${JUPYTER_CONFIG_DIR}
ENV CLING_STANDARD_PCH=none

###############################################################################
# Geant4
#
# - The normal ENV variables can be ommitted since we are installing to
#   a system path. We just need to copy the environment variables defining
#   the location of datasets. 
# - We configure Geant4 to always install the data to a specific path so 
#   the environment variables don't need to change if the version changes.
#
# Assumptions
#  - GEANT4 defined to be a release of geant4 or LDMX's fork of geant4
###############################################################################
ENV GEANT4=LDMX.10.2.3_v0.5
ENV G4DATADIR="${__prefix}/share/geant4/data"
LABEL geant4.version="${GEANT4}"
RUN __owner="geant4" &&\
    echo "${GEANT4}" | grep -q "LDMX" && __owner="LDMX-Software" &&\
    mkdir src &&\
    ${__wget} https://github.com/${__owner}/geant4/archive/${GEANT4}.tar.gz | ${__untar} &&\
    cmake \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_INSTALL_DATADIR=${G4DATADIR} \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
        -DGEANT4_USE_OPENGL_X11=ON \
        -DCMAKE_INSTALL_PREFIX=${__prefix} \
        -B src/build \
        -S src \
        &&\
    cmake --build src/build --target install -j$NPROC &&\
    rm -rf src 
ENV G4NEUTRONHPDATA="${G4DATADIR}/G4NDL4.6"
ENV G4LEDATA="${G4DATADIR}/G4EMLOW7.13"
ENV G4LEVELGAMMADATA="${G4DATADIR}/PhotonEvaporation5.7"
ENV G4RADIOACTIVEDATA="${G4DATADIR}/RadioactiveDecay5.6"
ENV G4PARTICLEXSDATA="${G4DATADIR}/G4PARTICLEXS3.1.1"
ENV G4PIIDATA="${G4DATADIR}/G4PII1.3"
ENV G4REALSURFACEDATA="${G4DATADIR}/RealSurface2.2"
ENV G4SAIDXSDATA="${G4DATADIR}/G4SAIDDATA2.0"
ENV G4ABLADATA="${G4DATADIR}/G4ABLA3.1"
ENV G4INCLDATA="${G4DATADIR}/G4INCL1.0"
ENV G4ENSDFSTATEDATA="${G4DATADIR}/G4ENSDFSTATE1.2.3"

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
# LHAPDF
#
# Needed for GENIE
#
# - We disable the python subpackage because it is based on Python2 whose
#   executable has been removed from Ubuntu 22.04.
###############################################################################
LABEL lhapdf.version="6.5.3"
RUN mkdir src &&\
    ${__wget} https://lhapdf.hepforge.org/downloads/?f=LHAPDF-6.5.3.tar.gz |\
      ${__untar} &&\
    cd src &&\
    ./configure --disable-python --prefix=${__prefix} &&\
    make -j$NPROC install &&\
    cd ../ &&\
    rm -rf src

###############################################################################
# GENIE
#
# Needed for ... GENIE :)
#
# - GENIE looks in ${ROOTSYS}/lib for various ROOT libraries it depends on.
#   This is annoying because root installs its libs to ${ROOTSYS}/lib/root
#   when the gnuinstall parameter is ON. We fixed this by forcing ROOT to
#   install its libs to ${ROOTSYS}/lib even with gnuinstall ON.
# - liblog4cpp5-dev from the Ubuntu 22.04 repos seems to be functional
# - GENIE's binaries link to pythia6 at runtime so we need to add the pythia6
#   library directory into the linker cache
# - GENIE reads its configuration from files written into its source tree
#   (and not installed), so we need to keep its source tree around
#
# Some errors from the build configuration
# - The 'quota: not found' error can be ignored. It is just saving a snapshot
#   of the build environment.
# - The 'cant exec git' error is resolved within the perl script which
#   deduces the version from the files in the .git directory if git is
#   not installed.
###############################################################################
LABEL genie.version=3.02.00
ENV GENIE_VERSION=3_02_00
#ENV GENIE_REWEIGHT_VERSION=1_02_00

ENV GENIE=/usr/local/src/GENIE/Generator

RUN mkdir -p ${GENIE} &&\
    ${__wget} https://github.com/GENIE-MC/Generator/archive/refs/tags/R-${GENIE_VERSION}.tar.gz |\
      ${__untar_to} ${GENIE} &&\
    cd ${GENIE} &&\
    ./configure \
      --enable-lhapdf6 \
      --disable-lhapdf5 \
      --enable-gfortran \
      --with-gfortran-lib=/usr/x86_64-linux-gnu/ \
      --disable-pythia8 \
      --with-pythia6-lib=${__prefix}/pythia6 \
      --enable-test \
    && \
    make -j$NPROC && \
    make -j$NPROC install

###############################################################################
# Catch2
###############################################################################
LABEL catch2.version=3.3.1
RUN mkdir -p src &&\
    ${__wget} https://github.com/catchorg/Catch2/archive/refs/tags/v3.3.1.tar.gz |\
      ${__untar} &&\
    cmake -B src/build -S src &&\
    cmake --build src/build --target install -- -j$NPROC &&\
    rm -rf src

###############################################################################
# Generate the linker cache
#    This should go AFTER all compiled dependencies so that the ld cache 
#    contains all of them.
#    Ubuntu includes /usr/local/lib in the linker cache generation by default,
#    so dependencies just need to write a ld conf file if their libs do not
#    get installed to that directory (e.g. ROOT)
###############################################################################
RUN ldconfig -v

###############################################################################
# Extra python packages for analysis
###############################################################################
COPY ./python_packages.txt /etc/python_packages.txt
RUN python3 -m pip install --no-cache-dir --requirement /etc/python_packages.txt

# add any ssl certificates to the container to trust
COPY ./certs/ /usr/local/share/ca-certificates
RUN update-ca-certificates

#run environment setup when docker container is launched and decide what to do from there
#   will require the environment variable LDMX_BASE defined
COPY ./entry.sh /etc/
RUN chmod 755 /etc/entry.sh
ENTRYPOINT ["/etc/entry.sh"]

