# docker
Docker build context for developing and running ldmx-sw.

Docker has developed a [GitHub action](https://github.com/marketplace/actions/build-and-push-docker-images) that can automatically build docker images and push them to dockerhub. 
I hope to use this action so that we can easily update any images that we wish.

In the long run, we could setup a workflow where a new production running docker image is generated with any commits or releases on the master branch.

- Helpful stack overflow: https://stackoverflow.com/a/49848507
- Docker Action: https://github.com/marketplace/actions/build-and-push-docker-images

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
