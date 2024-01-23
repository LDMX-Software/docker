# Running these Images

These images are built with all of the software necessary to build and run ldmx-sw;
however, the image makes a few assumptions about how it will be launched into a container
so that it can effectively interact with the source code that resides on the host machine.

We can enforce other choices on users to make the usage of these images easier (see the
`ldmx-env.sh` script in ldmx-sw for details), but there are a minimum of two requirements
that _must_ be met in order for the image to operate.

> The following sections provide **examples** of implementing the running of these images
in a few common container runners. The full implementation used by LDMX is written
into the `ldmx-env.sh` environment script.

### LDMX_BASE
The environment variable `LDMX_BASE` must be defined for the container. This is then
mounted into the container as the workspace where most (if not all) of the files the
container must view on the host reside. In ldmx-sw, we choose to have `LDMX_BASE` be
the parent directory of the ldmx-sw repository, but that is not necessary.

### ldmx-sw install location
Within the entrypoint for the container, we add a few paths relative to `$LDMX_BASE`
to various `PATH` shell variables so that the shell executing within the container
can find executables to run and libraries to link. All of the paths are subdirectories
of `$LDMX_BASE/ldmx-sw/install`[^1] which implies that ldmx-sw must be installed to
this directory if users wish to run their developments within the container.
This install location is put into the ldmx-sw CMakeLists.txt so users will not need
to change it unless they wish to do more advanced development.

[^1]: See [LDMX-Software/docker Issue #38](https://github.com/LDMX-Software/docker/issues/38).
We may change this assumption to make it clearer that other packages could be installed at this location besides ldmx-sw.

## Determining an Image's Version
Often it is helpful to determine an image's version. Sometimes, this is as easy as
looking at the tag provided by `docker image ls` or written into the SIF file name,
but sometimes this information is lost. Since v4 of the container image, we've been
more generous with adding labels to the image and a standard one is included
`org.opencontainers.image.version` which (for our purposes) stores the release that
built the image.

We can `inspect` an image to view its labels.
```shell
# docker inspect returns JSON with all the image manifest details
# jq just helps us parse this JSON for the specific thing we are looking for,
# but you could just scroll through the output of docker inspect
docker inspect ldmx/dev:latest | jq 'map(.Config.Labels["org.opencontainers.image.version"])[]'
# apptainer inspect (by default) returns just the list of labels
# so we can just use grep to select the line with the label we care about
apptainer inspect ldmx_dev_latest | grep org.opencontainers.image.version
```
