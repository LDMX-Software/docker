
FROM ubuntu:18.04
LABEL ubuntu.version="18.04"
MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

# First install any required dependencies from ubuntu repos
# Ongoing documentation for this list is in docs/ubuntu-packages.md
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        binutils \
        ca-certificates \
        fonts-freefont-ttf \
        g++-7 \
        gcc-7 \
        libfftw3-dev \
        libfreetype6-dev \
        libftgl-dev \
        libgif-dev \
        libgl1-mesa-dev \
        libgl2ps-dev \
        libglew-dev \
        libglu-dev \
        libjpeg-dev \
        liblz4-dev \
        liblzma-dev \
        libpcre++-dev \
        libpng-dev \
        libssl-dev \
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
    python3 -m pip install --upgrade --no-cache-dir cmake

###############################################################################
# Source-Code Downloading Method
#   mkdir src && ${__wget} <url-to-tar.gz-source-archive> | ${__untar}
#
#   Adapted from acts-project/machines
###############################################################################
ENV __wget wget -q -O -
ENV __untar tar -xz --strip-components=1 --directory src
ENV __prefix /usr
ENV __ldmx_env_script_d__ /etc/ldmx-container-env.d

# All init scripts in this directory will be run upon entry into container
RUN mkdir ${__ldmx_env_script_d__}

# add any ssl certificates to the container to trust
COPY ./certs/ /usr/local/share/ca-certificates
RUN update-ca-certificates

#run environment setup when docker container is launched and decide what to do from there
#   will require the environment variable LDMX_BASE defined
COPY ./entry.sh /etc/
RUN chmod 755 /etc/entry.sh
ENTRYPOINT ["/etc/entry.sh"]

###############################################################################
# Boost
###############################################################################
LABEL boost.version="1.76.0"
RUN mkdir src &&\
    ${__wget} https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz |\
      ${__untar} &&\
    cd src &&\
    ./bootstrap.sh &&\
    ./b2 install &&\
    ldconfig &&\
    cd .. && rm -rf src

###############################################################################
# HDF5
###############################################################################
LABEL hdf5.version="1.12.1"
RUN mkdir src &&\
    ${__wget} https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_12_1.tar.gz |\
      ${__untar} &&\
    cd src &&\
    ./configure \
      --prefix=${__prefix} \
      --enable-cxx &&\
    make install &&\
    ldconfig &&\
    cd .. && rm -rf src

###############################################################################
# HighFive
###############################################################################
LABLE highfive.version="2.3.1"
RUN mkdir src &&\ 
    ${__wget} https://github.com/BlueBrain/HighFive/archive/refs/tags/v2.3.1.tar.gz |\
      ${__untar} &&\
    cmake \
      -B src/build \
      -S src \
      -DCMAKE_INSTALL_PREFIX=${__prefix} &&\
    cmake \
      --build src/build \
      --target install &&\
    rm -rf src

###############################################################################
# Extra python packages for analysis
###############################################################################
RUN python3 -m pip install --upgrade --no-cache-dir \
        h5py \
        pandas \
        numpy \
        matplotlib \
        xgboost \
        sklearn
