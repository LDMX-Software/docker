# Ubuntu Packages
Here I try to list all of the installed ubuntu packages and give an explanation of why they are included.
Lot's of these packages are installed into the [ROOT official docker container](https://github.com/root-project/root-docker/blob/master/ubuntu/Dockerfile) and so I have copied them here. I don't know what their purpose is or if they are necessary or even helpful.

Package | Reason
---|---
binutils |
ca-certificates | Installing certificates to trust in container
davix-dev |
dcap-dev |
dpkg-dev |
fonts-freefont-ttf |
g++-7 | Compiler with C++17 support
gcc-7 | Compiler with C++17 support
git | Downloading dependency sources
libafterimage-dev |
libboost-all-dev | ldmx-sw direct dependency
libcfitsio-dev |
libfcgi-dev |
libfftw3-dev |
libfreetype6-dev |
libftgl-dev |
libgfal2-dev |
libgif-dev |
libgl1-mesa-dev |
libgl2ps-dev |
libglew-dev |
libglu-dev |
libgraphviz-dev |
libgsl-dev |
libjpeg-dev |
liblz4-dev |
liblzma-dev |
libmysqlclient-dev |
libpcre++-dev |
libpng-dev |
libpq-dev |
libpythia8-dev |
libsqlite3-dev |
libssl-dev |
libtbb-dev |
libtiff-dev |
libx11-dev |
libxext-dev |  
libxft-dev |
libxml2-dev |
libxmu-dev |
libxpm-dev |
libz-dev |
libzstd-dev |
locales |
make | Building dependencies and ldmx-sw source
python-dev | ROOT TPython
python-pip | For downloading more python packages later
python-numpy | ROOT TPython requires numpty
python-tk | matplotlib requires python-tk for some plotting
python3-dev | ROOT TPython and ldmx-sw ConfigurePython
python3-pip | For downloading more python packages later
python3-numpy | ROOT TPython requires numpy
python3-tk | matplotlib requires python-tk for some plotting
srm-ifce-dev |
unixodbc-dev | 
wget | Download Xerces-C source and dowload Conditions tables in ldmx-sw
