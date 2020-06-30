# docker

Docker build context for developing and running ldmx-sw.

Docker has developed a [GitHub action](https://github.com/marketplace/actions/build-and-push-docker-images) that can automatically build docker images and push them to dockerhub. 
That action is used here to automatically build and propagate any changes to docker hub.

**I have turned off actions running on this repository now that I have wrapped up development of this image.**
I did this because I don't want someone accidentally breaking the `latest` build on dockerhub.
I want to still leave the building action in the repository so that if/when development on this image resumes, 
we can still use github runners to do the heavy lifting.

In the long run, we could setup a workflow where a new production running docker image is generated with any commits or releases on the master branch.
This would entail constructing another docker image that uses this one as a base image,
but then includes the ldmx-sw source code.

### Use in ldmx-sw

The use of this docker image will be paired with a few bash aliases that will allow the user to run high level docker commands without needing to understand docker or change their workflow. 
The core alias hides the docker run action from everyone else:
```bash
alias ldmx='docker run --rm -it -e LDMX_BASE -v $LDMX_BASE:$LDMX_BASE ldmx/dev $(pwd)'
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
 
 ## Singularity
 
 You can convert both this image and the production image into singularity images using singularity itself.
 For example, to convert the development image stored on docker-hub you would
 ```
 singularity build ldmx_dev_latest.sif docker://ldmx/dev:latest
 ```
 This command pulls down the layers for the development image from docker hub and builds it into the singularity `.sif` file.
 Using the image with singularity can be done in the same way as with docker if you define the following function
 ```
 function ldmx() {
     _current_working_dir=${PWD##"${LDMX_BASE}/"} #store current working directory relative to ldmx base
     cd ${LDMX_BASE} # go to ldmx base directory outside container
     # actually run the singularity image stored in the base directory going to working directory inside container
     singularity run --no-home ${LDMX_SINGULARITY_IMG} ${_current_working_dir} "$@"
     cd - &> /dev/null #go back outside the container
 }
 ```
 Since singularity mounts the current working directory to the container automatically, we go back to `${LDMX_BASE}` and enter the container from there.
 Then we can go back to the user's working directory inside of the container to run our command.
