# Use Development Container with `docker`

### Assumptions
- Docker engine is installed on your computer
- (For linux systems), you can manage `docker` as a non-root user

### Environment Setup
0. Decide what tag you want to use: `export LDMX_DOCKER_TAG="ldmx/dev:my-tag"`
1. Pull down desired docker image: `docker pull ${LDMX_DOCKER_TAG}`
2. Define a helpful alias:
```
alias ldmx='docker run --rm -it -e LDMX_BASE -v $LDMX_BASE:$LDMX_BASE ${LDMX_DOCKER_TAG} $(pwd)'
```
3. Define the directory that _ldmx-sw_ is in:
```
cd <path-to-directory-containing-ldmx-sw>
export LDMX_BASE=$(pwd -P)
```

### Using the Container
Prepend any commands you want to run with _ldmx-sw_ with the container alias you defined above.
For example, to configure the ldmx-sw build, `ldmx cmake ..` (instead of just `cmake ..`).

### Detailed `docker run` explanation
```bash
docker \ #base docker command
    run \ #run the container
    --rm \ #clean up container after execution finishes
    -it \ #make container interactive
    -e LDMX_BASE \ #pass environment variable to container
    -v $LDMX_BASE:$LDMX_BASE \ #mount filesystem to container
    -u $(id -u ${USER}):$(id -g ${USER}) \ #act as current user
    ${LDMX_DOCKER_TAG} \ #docker image to build container from
    $(pwd) \ #go to present directory inside the continaer
```

### Display Connection
In order to connect the display, you need to add two more parameters to the above `docker run` command.
When running [docker inside of the Windoze Subsystem for Linux (WSL)](https://docs.docker.com/docker-for-windows/wsl/),
you will also need to have an external X server running _outside_ WSL.
Ubuntu has a good [tutorial on how to get graphical applications running inside WSL](https://wiki.ubuntu.com/WSL).

0. Define how to interface wiith the display.
   - For Linux: `export LDMX_CONTAINER_DISPLAY=""`
   - For MacOS: `export LDMX_CONTAINER_DISPLAY="docker.for.mac.host.internal"`
   - For WSL: `export LDMX_CONTAINER_DISPLAY=$(awk '/nameserver / ${print$2; exit}' /etc/resolv.conf 2>/dev/null)`[^1]
1. Define the `DISPLAY` environment variable for inside the container. `-e DISPLAY=${LDMX_CONTAINER_DISPLAY}:0`
2. Mount the cache directory for the window manager for the container to share. `-v /tmp/.X11-unix:/tmp/.X11-unix`

[^1]: [WSL Graphical Apps on Ubuntu Wiki](https://wiki.ubuntu.com/WSL?&_ga=2.29286004.935441070.1627417257-513300802.1627417257#Running_Graphical_Applications)
