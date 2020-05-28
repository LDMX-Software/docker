
FROM ubuntu:18.04

LABEL ldmxsw.version="2.0.0" \
      root.version="6.20.00" \
      geant4.version="10.2.3.v0.3" \
      ubuntu.version="18.04" \
      xerces.version="3.2.3" \
      onnx.version="1.3.0"

MAINTAINER Tom Eichlersmith <eichl008@umn.edu>

# First install any required dependencies from ubuntu repos
#   TODO clean up this dependency list
RUN apt-get update \
    && apt-get install -y \
        wget \
        git \
        cmake \
        dpkg-dev \
        python-dev \
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
        libgl1-mesa-dev \
    && apt-get update

RUN mkdir install-scripts
COPY . /install-scripts

# Let's build and install our dependencies
RUN /bin/bash install-scripts/install-root.sh

ENV XercesC_DIR /xerces-c/install
RUN /bin/bash install-scripts/install-xerces.sh

RUN /bin/bash install-scripts/install-geant4.sh

ENV ONNX_DIR /onnxruntime
RUN /bin/bash install-scripts/install-onnxruntime.sh

# any extra cleanup
RUN apt-get clean && apt-get autoremove && rm -rf /install-scripts

# Make a non-super user and become them
RUN useradd --user-group --system --create-home --no-log-init --shell /bin/bash ldmx-user
USER ldmx-user
WORKDIR /home/ldmx-user

# Add setup environment to their automatically loaded bashrc
#   This will need to be changed if the install locations change
RUN echo "source /cernroot/install/bin/thisroot.sh" >> .bashrc \
    && echo "source /geant4/install/bin/geant4.sh"  >> .bashrc \
    && echo "export LD_LIBRARY_PATH=$ONNX_DIR/lib:$LD_LIBRARY_PATH" >> .bashrc
