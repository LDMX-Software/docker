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
