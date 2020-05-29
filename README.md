# docker

**Not Stable**

Docker build context for developing and running ldmx-sw.

Docker has developed a [GitHub action](https://github.com/marketplace/actions/build-and-push-docker-images) that can automatically build docker images and push them to dockerhub. 
That action is used here to automatically build and propagate any changes to docker hub.

In the long run, we could setup a workflow where a new production running docker image is generated with any commits or releases on the master branch.
This would entail constructing another docker image that uses this one as a base image, but then includes the ldmx-sw source code.

### Use in ldmx-sw

The use of this docker image will be paired with a few bash aliases that will allow the user to run high level docker commands without needing to understand docker or change their workflow. 
The core alias hides the docker run action from everyone else:
```bash
alias ldmx='docker run --rm -it -e LDMX_BASE -v $LDMX_BASE:$LDMX_BASE tomeichlersmith/ldmx-os $(pwd)'
```
This launches the docker container, essentially putting the user into the ldmx environment, and then enters the directory that the user is running this alias from.
Any commands passed to this alias are then run in the container on the mounted directory that the user is on.
This means the user would have the following workflow:
```bash
$ export LDMX_BASE=<path-to-directory-containing-ldmx-sw>
$ cd $LDMX_BASE/ldmx-sw
$ mkdir build; cd build;
$ ldmx cmake -DBUILD_EVE=OFF -DONNXRUNTIME_ROOT=/deps/onnxruntime -DCMAKE_INSTALL_PREFIX=../install ../
...
cmake output like normal
...
$ ldmx make install
...
make build output like normal
...
```
Isn't that wonderful???

### Development

Places to make the image smaller:
 - More specific apt-get packages that are required (`--no-install-recommends`)
 - More specific minimal root build
 - Selective Geant4 data downloads
   - Maybe mount Geant4 data from the host?
 - Smaller base image (starting from full ubuntu 18.04 server right now)
