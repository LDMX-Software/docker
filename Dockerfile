
FROM ubuntu:18.04

# Geant4 and ROOT version arguments
# are formatted as the branch/tag to 
# pull from git
ARG GEANT4=LDMX.up-kaons
ARG ROOT=v6-22-00-patches
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
      xerces.version="${XERCESC}"

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
        wget \
        git \
        dpkg-dev \
        python-dev \
        python-pip \
        python-numpy \
        python-tk \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-tk \
        make \
        g++-7 \
        gcc-7 \
        binutils \
        libx11-dev \
        libxpm-dev \
        libxft-dev \
        libxext-dev \
        libboost-all-dev \
        libxmu-dev \
        libgl1-mesa-dev &&\
    python3 -m pip install --upgrade --no-cache-dir cmake

# put installation scripts into temporary directory for later cleanup
COPY install-scripts/ /tmp/

# decide where our three big external dependency will be installed
ENV ROOTDIR /deps/cernroot
ENV XercesC_DIR /deps/xerces-c
ENV G4DIR /deps/geant4

# run installation scripts and then remove them (and any generated files)
RUN /bin/bash /tmp/install-root.sh        &&\
    /bin/bash /tmp/install-xerces.sh      &&\
    /bin/bash /tmp/install-geant4.sh      &&\
    rm -rf /tmp/*

# clean up source and build files from apt-get
RUN apt-get clean && apt-get autoremove 

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
