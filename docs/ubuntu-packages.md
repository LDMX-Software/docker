# Ubuntu Packages
Here I try to list all of the installed ubuntu packages and give an explanation of why they are included.
Lot's of these packages are installed into the [ROOT official docker container](https://github.com/root-project/root-docker/blob/master/ubuntu/Dockerfile) and so I have copied them here. 
I have looked into their purpose by a combination of googling the package name and looking at [ROOT's reason for them](https://root.cern/install/dependencies/). 

Package | Necessary | Reason
---|---|---
apt-utils | Yes | Necessary for distrobox support
autoconf | Yes | Configuration of log4cpp build, needed for GENIE
automake | Yes | Configuration of log4cpp build, needed for GENIE
binutils | Yes | Adding PPA and linking libraries
bc | Yes | Necessary for distrobox support
ca-certificates | Yes | Installing certificates to trust in container
curl | Yes | Necessary for distrobox support
cmake | Yes | Make configuration, v3.22.1 available in Ubuntu 22.04 repos
dialog | Yes | Necessary for distrobox support
diffutils | Yes | Necessary for distrobox support
davix-dev | No | Remote I/O, file transfer and file management
dcap-dev | Unknown | C-API to the [DCache Access Protocol](https://dcache.org/old/manuals/libdcap.shtml)
dpkg-dev | No | **Old** Installation from PPA
findutils | Yes | Necessary for distrobox support
fonts-freefont-ttf | Yes | Fonts for plots
g++ | Yes | Compiler with C++17 support, v11 available in Ubuntu 22.04 repos
gcc | Yes | Compiler with C++17 support, v11 available in Ubuntu 22.04 repos
gdb | No | Supporting debugging LDMX-sw programs within the container
gfortran | Yes | FORTRAN compiler; needed for compiling Pythia6, which in turn is needed for GENIE
gnupg2 | Yes | Necessary for distrobox support
git | No | **Old** Downloading dependency sources
less | Yes | Necessary for distrobox support
libafterimage-dev | Yes | ROOT GUI depends on these for common shapes
libasan8 | No | Runtime components for the compiler based instrumentation tools that come with GCC
libboost-all-dev | Yes | Direct ldmx-sw dependency, v1.74 available in Ubuntu 22.04 repos
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
libgsl-dev | Yes | GNU Scientific library for numerical calculations; needed for GENIE
libjpeg-dev | Yes | Saving plots as JPEGs
liblz4-dev | Yes | Data compression
liblzma-dev | Yes | Data compression
libmysqlclient-dev | No | Interact with SQL database
libnss-myhostname | Yes | Necessary for distrobox support
libpcre++-dev | Yes | Regular expression pattern matching
libpng-dev | Yes | Saving plots as PNGs
libpq-dev | No | Light binaries and headers for PostgreSQL applications
libpythia8-dev | No | [Pythia8](http://home.thep.lu.se/~torbjorn/pythia81html/Welcome.html) HEP simulation
libsqlite3-dev | No | Interact with SQL database
libssl-dev | Yes | Securely interact with other computers and encrypt files
libtbb-dev | No | Multi-threading
libtiff-dev | No | Save plots as TIFF image files
libtool | Yes | Needed for log4cpp build, in turn needed for GENIE
libvte-2.9[0-9]-common | Yes | Necessary for distrobox support
libvte-common | Yes | Necessary for distrobox support
libx11-dev | Yes | Low-level window management with X11
libxext-dev | Yes | Low-level window management
libxft-dev | Yes | Low-level window management
libxml2-dev | Yes | Low-level window management
libxmu-dev | Yes | Low-level window management
libxpm-dev | Yes | Low-level window management
libz-dev | Yes | Data compression
libzstd-dev | Yes | Data compression
lsof | Yes | Necessary for distrobox support
locales | Yes | Configuration of TPython and other python packages
make | Yes | Building dependencies and ldmx-sw source
ncurses-base | Yes | Necessary for distrobox support
passwd | Yes | Necessary for distrobox support
pinentry-curses | Yes | Necessary for distrobox support
procps | Yes | Necessary for distrobox support
python3-dev | Yes | ROOT TPython and ldmx-sw ConfigurePython
python3-pip | Yes | For downloading more python packages later
python3-numpy | Yes | ROOT TPython requires numpy
python3-tk | Yes | matplotlib requires python-tk for some plotting
sudo | Yes | Necessary for distrobox support
srm-ifce-dev | Unknown | Unknown
time | Yes | Necessary for distrobox support
unixodbc-dev | No | Access different data sources uniformly
util-linux | Yes | Necessary for distrobox support
wget | Yes | Download Xerces-C source and dowload Conditions tables in ldmx-sw
