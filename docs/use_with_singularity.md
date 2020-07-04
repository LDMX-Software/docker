# Use Development Container with Singularity

### Assumptions
- Singularity is installed on your computer
- You have permission to run `singularity build` and `singularity run`.

### Environment Setup
0. Decide what tag you want to use: `export LDMX_DOCKER_TAG="ldmx/dev:my-tag"`
1. Name the singularity image that will be built: `export LDMX_SINGULARITY_IMG="$(pwd -P)/ldmx_dev_my-tag.sif"`
2. Pull down desired docker image and convert it to singularity style: `singularity build ${LDMX_SINGULARITY_IMG} docker://${LDMX_DOCKER_TAG}`
3. Define a helpful bash function:
```bash
function ldmx() {
    _current_working_dir=${PWD##"${LDMX_BASE}/"} #store current working directory relative to ldmx base
    cd ${LDMX_BASE} # go to ldmx base directory outside container
    # actually run the singularity image stored in the base directory going to working directory inside container
    singularity run --no-home ${LDMX_SINGULARITY_IMG} ${_current_working_dir} "$@"
    cd - &> /dev/null #go back outside the container
}
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
    ${LDMX_SINGULARITY_IMG} \ #full path to singularity image to make container out of
    ${_current_working_dir} \ #go to the working directory after entering the container
    "$@" #run the arguments given by the user as a command in the container
```
