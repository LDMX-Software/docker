# Ubuntu Packages
Here I try to list all of the installed ubuntu packages and give an explanation of why they are included.
Lot's of these packages are installed into the [ROOT official docker container](https://github.com/root-project/root-docker/blob/master/ubuntu/Dockerfile) and so I have copied them here. 
I have looked into their purpose by a combination of googling the package name and looking at [ROOT's reason for them](https://root.cern/install/dependencies/). 

Package | Necessary | Reason
---|---|---
binutils | Yes | Adding PPA and linking libraries
ca-certificates | Yes | Installing certificates to trust in container
davix-dev | No | Remote I/O, file transfer and file management
dcap-dev | Unknown | C-API to the [DCache Access Protocol](https://dcache.org/old/manuals/libdcap.shtml)
dpkg-dev | Yes | Installation from PPA
fonts-freefont-ttf | Yes | Fonts for plots
g++-7 | Yes | Compiler with C++17 support
gcc-7 | Yes | Compiler with C++17 support
git | No | **Old** Downloading dependency sources
libafterimage-dev | Unknown | Unknown
libcfitsio-dev | No | Reading and writing in [FITS](https://heasarc.gsfc.nasa.gov/docs/heasarc/fits.html) data format
libfcgi-dev | No | Open extension of CGI for internet applications
libfftw3-dev | Yes | Computing discrete fourier transform
libfreetype6-dev | Yes | Fonts for plots
libftgl-dev | Yes | Rendering fonts in OpenGL
libgfal2-dev | No | Toolkit for file management across different protocols
libgif-dev | Yes | Saving plots as GIFs
libgl1-mesa-dev | Yes | [MesaGL](https://mesa3d.org/) allowing 3D rendering using OpenGL
libgl2ps-dev | Yes | Convert OpenGL image to PostScript file
libglew-dev | Yes | [GLEW](http://glew.sourceforge.net/) library for helping use OpenGL
libglu-dev | Yes | [OpenGL Utility Library](https://www.opengl.org/resources/libraries/)
libgraphviz-dev | No | Graph visualization library
libgsl-dev | No | GNU Scientific library for numerical calculations
libjpeg-dev | Yes | Saving plots as JPEGs
liblz4-dev | Yes | Data compression
liblzma-dev | Yes | Data compression
libmysqlclient-dev | No | Interact with SQL database
libpcre++-dev | Yes | Regular expression pattern matching
libpng-dev | Yes | Saving plots as PNGs
libpq-dev | No | Light binaries and headers for PostgreSQL applications
libpythia8-dev | No | [Pythia8](http://home.thep.lu.se/~torbjorn/pythia81html/Welcome.html) HEP simulation
libsqlite3-dev | No | Interact with SQL database
libssl-dev | Yes | Securely interact with other computers and encrypt files
libtbb-dev | No | Multi-threading
libtiff-dev | No | Save plots as TIFF image files
libx11-dev | Yes | Low-level window management with X11
libxext-dev | Yes | Low-level window management
libxft-dev | Yes | Low-level window management
libxml2-dev | Yes | Low-level window management
libxmu-dev | Yes | Low-level window management
libxpm-dev | Yes | Low-level window management
libz-dev | Yes | Data compression
libzstd-dev | Yes | Data compression
locales | Yes | Configuration of TPython and other python packages
make | Yes | Building dependencies and ldmx-sw source
python3-dev | Yes | ROOT TPython and ldmx-sw ConfigurePython
python3-pip | Yes | For downloading more python packages later
python3-numpy | Yes | ROOT TPython requires numpy
python3-tk | Yes | matplotlib requires python-tk for some plotting
srm-ifce-dev | Unknown | Unknown
unixodbc-dev | No | Access different data sources uniformly
wget | Yes | Download Xerces-C source and dowload Conditions tables in ldmx-sw
