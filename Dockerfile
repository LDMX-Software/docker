
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

COPY install-scripts/ /tmp/

# Let's build and install our dependencies
RUN /bin/bash /tmp/install-root.sh

ENV XercesC_DIR /xerces-c/install
RUN /bin/bash /tmp/install-xerces.sh

RUN /bin/bash /tmp/install-geant4.sh

ENV ONNX_DIR /onnxruntime
RUN /bin/bash /tmp/install-onnxruntime.sh

# any extra cleanup
RUN apt-get clean && apt-get autoremove && rm -rf /tmp/*

# Make a non-super user and become them
RUN useradd --user-group --system --create-home --no-log-init --shell /bin/bash ldmx-user
USER ldmx-user
WORKDIR /home/ldmx-user

# Add setup environment to their automatically loaded bashrc
#   This will need to be changed if the install locations change
ENV LDMX_SW_INSTALL /home/ldmx-user/ldmx-sw/install
ENV LDMX_SW_BUILD   /home/ldmx-user/ldmx-sw/build
ENV LDMX_ANA_INSTALL /home/ldmx-user/ldmx-analysis/install
ENV LDMX_ANA_BUILD   /home/ldmx-user/ldmx-analysis/build
RUN mkdir -p $LDMX_SW_INSTALL $LDMX_SW_BUILD $LDMX_ANA_INSTALL $LDMX_ANA_BUILD \ 
    && echo "source /cernroot/install/bin/thisroot.sh" >> .bashrc \
    && echo "source /geant4/install/bin/geant4.sh"  >> .bashrc \
    && echo "export LD_LIBRARY_PATH=$ONNX_DIR/lib:$LDMX_SW_INSTALL/lib:$LD_LIBRARY_PATH" >> .bashrc \
    && echo "export PYTHONPATH=$LDMX_SW_INSTALL/lib/python:$LDMX_ANA_INSTALL/lib/python:$PYTHONPATH" >> .bashrc \
    && echo "export PATH=$LDMX_SW_INSTALL/bin:$PATH" >> .bashrc
