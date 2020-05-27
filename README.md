# docker

**Not Stable**

Docker build context for developing and running ldmx-sw.

Docker has developed a [GitHub action](https://github.com/marketplace/actions/build-and-push-docker-images) that can automatically build docker images and push them to dockerhub. 
That action is used here to automatically build and propagate any changes to docker hub.

In the long run, we could setup a workflow where a new production running docker image is generated with any commits or releases on the master branch.
This would entail constructing another docker image that uses this one as a base image, but then includes the ldmx-sw source code.

### Use in ldmx-sw

The use of this docker image will be paired with a few bash aliases that will allow the user to run high level docker commands without needing to understand docker or change their workflow. Some expected aliases are:
Command | Docker Synopsis | Description
---|---|---
`ldmx-env` | `docker start ...` | pull docker image, start up docker container, mount working diretory to docker container
`ldmx-cmake` | `docker exec ... <insert-working-cmake-command-here>` | configures the build in the container
`ldmx-make [args]` | `docker exec ... make [args]` | passes make and its arguments to the container
`ldmx-remake` | combo | removes old build and install and rebuilds and reinstalls from scratch, uses all but one processor
`ldmx-app [args]` | `docker exec ... ldmx-app [args]` | runs ldmx-app with its arguments in container
`ldmx-val [args]` | `docker exec ... valgrind ldmx-app [args]` | **maybe** runs ldmx-app inside valgrind in container)
`ldmx-close` | `docker stop ...` | **maybe** clean up and stop docker container

The dots `...` represent some extra docker options that will be figured out to help the user.

### Development

Places to make the image smaller:
 - More specific apt-get packages that are required (`--no-install-recommends`)
 - More specific minimal root build
 - Selective Geant4 data downloads
   - Maybe mount Geant4 data from the host?
 - Smaller base image (starting from full ubuntu 18.04 server right now)
