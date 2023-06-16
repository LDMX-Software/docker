# CI for ldmx development container image

In order to be able to test multiple tags of ldmx-sw in parallel,
we package the new build into a `tar` archive using `docker save`.
These archive is what is uploaded to GitHub as an "artifact" that
can then be downloaded by later jobs in the workflow _and_ we can
download the artifact for debugging purposes.

After downloading the artifact, we will have a `tar` ball with all
of the docker layers in it. You need to "unpack" this archive using
the container runner on your computer.

Runner | Command
---|---
docker | [`docker load --input <tar-ball>`](https://docs.docker.com/engine/reference/commandline/load/)
singularity | [`singularity build <new-sif> docker-archive://<tar-ball>`](https://sylabs.io/guides/3.1/user-guide/singularity_and_docker.html#locally-available-images-stored-archives)

Downloading the artifact with `gh` results in the tar ball, but downloading
it from the website results in a zipped version of the tar ball. One can
still load this into docker (without intermediate files) with
```
unzip -p <ldmx-dev-SHA.zip> | docker load
```

## Legacy Interop
For some past versions of ldmx-sw, we need to modify the code slightly 
in order for it to be able to be built by the newer containers. For
this reason, we have a set of (interop)[../interop] scripts. If there
is a directory corresponding to the version being tested, then the
CI will run the scripts in that directory before attempting to build
and install ldmx-sw.

If there are interop patches, we assume that the testing is also
not functional so neither the test program nor a test simulation
are run.
