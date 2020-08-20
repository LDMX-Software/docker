
FROM ubuntu:18.04

# Geant4 and ROOT version arguments
# are formatted as the branch/tag to 
# pull from git
ARG GEANT4=LDMX.10.2.3_v0.3
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
RUN apt-get update &&\
    apt-get install -y \
        wget \
        git \
        dpkg-dev \
        python-dev \
        python-pip \
        python-numpy \
        python3-dev \
        python3-pip \
        python3-numpy \
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

# move to location to keep working files
COPY install-scripts/ /tmp/

# Let's build and install our dependencies
ENV ROOTDIR /deps/cernroot
ENV XercesC_DIR /deps/xerces-c
ENV G4DIR /deps/geant4

RUN /bin/bash /tmp/install-root.sh        &&\
    /bin/bash /tmp/install-xerces.sh      &&\
    /bin/bash /tmp/install-geant4.sh      &&\
    rm -rf /tmp/*

# clean up source and build files
RUN apt-get clean && apt-get autoremove 

#copy over necessary running script
COPY ./ldmx.sh /home/
RUN chmod 755 /home/ldmx.sh

# extra python packages
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

#run environment setup when docker container is launched
# and decide what to do from there
#   will require the environment variable LDMX_BASE defined
ENTRYPOINT ["/home/ldmx.sh"]
