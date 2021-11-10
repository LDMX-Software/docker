# Use Development Container with Singularity

### Assumptions
- Singularity is installed on your computer
- You have permission to run `singularity build` and `singularity run`.

### Environment Setup
0. Decide what tag you want to use: `export LDMX_DOCKER_TAG="ldmx/dev:my-tag"`
1. Name the singularity image that will be built: `export LDMX_SINGULARITY_IMG="$(pwd -P)/ldmx_dev_my-tag.sif"`
2. Pull down desired docker image and convert it to singularity style: `singularity build ${LDMX_SINGULARITY_IMG} docker://${LDMX_DOCKER_TAG}`
    - You may need to point `singularity` to a larger directory using the `SINGULARITY_CACHEDIR` environment variable
3. Define a helpful bash alias:
```bash
alias ldmx='singularity run --no-home --bind ${LDMX_BASE} --cleanenv --env LDMX_BASE=${LDMX_BASE} ${LDMX_SINGULARITY_IMG} $(pwd)'
```
4. Define the directory that _ldmx-sw_ is in:
```
cd <path-to-directory-containing-ldmx-sw>
export LDMX_BASE=$(pwd -P)
```

### Using the Container
Prepend any commands you want to run with _ldmx-sw_ with the container alias you defined above.
For example, to configure the ldmx-sw build, `ldmx cmake ..` (instead of just `cmake ..`).
_Notice that using this container after the above setup is identical to using this container with docker._

### Detailed `singularity run` explanation
`singularity`'s default behavior is to mount the current directory into the container.
This means we go to the `$LDMX_BASE` directory so that the container will have access to everything inside `$LDMX_BASE`.
Then we enter the container there before going back to where the user was _while inside the container_.
```bash
singularity \ #base singularity command
    run \ #run the container
    --no-home \ #don't mount home directory (might overlap with current directory)
    --bind ${LDMX_BASE} \ #mount the directory containting all things LDMX
    --cleanenv \ #don't copy the environment variables into the container
    --env LDMX_BASE=${LDMX_BASE} \ #copy the one environment variable we need shared with the container
    ${LDMX_SINGULARITY_IMG} \ #full path to singularity image to make container out of
    $(pwd) \ #go to the working directory after entering the container
```

### Display Connection

I've only been able to determine how to connect the display when on Linux systems.
The connection procedure is similar to [docker](docs/use_with_docker.md#display-connection).

1. Pass the `DISPLAY` environment variable to the container `--env LDMX_BASE=${LDMX_BASE},DISPLAY=:0`
2. Mount the cache directory for the window manager `--bind ${LDMX_BASE},/tmp/.X11`
