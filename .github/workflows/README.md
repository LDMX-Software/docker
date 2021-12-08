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

