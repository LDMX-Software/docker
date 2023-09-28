# Container with Custom Geant4

Geant4 is our main simulation engine and it has a large effect on the products of our simulation samples.
As such, it is very common to compare multiple differnt versions, patches, and tweaks to Geant4 with our simulation.

With this in mind, the container is allowed to build (almost) any release of Geant4, pulling either from the [official Geant4 repository](https://github.com/Geant4/geant4) or pulling from [LDMX's fork](https://github.com/LDMX-Software/geant4) if "LDMX" appears in the tag name requested.

Most of the newer versions of Geant4 can be built the same as the current standard [LDMX.10.2.3_v0.4](https://github.com/LDMX-Software/geant4/releases/tag/LDMX.10.2.3_v0.4), so to change the tag that you want to use in the container you simply need to change the `GEANT4` parameter in the Dockerfile.

```
...a bunch of crap...
ENV GEANT4=LDMX.10.2.3_v0.4 #CHANGE ME TO YOUR TAG NAME
... other crap ...
```

Changing this parameter _could_ be all you need, but if the build is not completing properly, you may need to change the `RUN` command that actually builds Geant4.

## Building

To build a docker container, one would normally go into this repository and simply run `docker build . -t ldmx/dev:my-special-tag`, but since this container takes so long to build, if you are only making a small change, you can simply create a new branch in this repository and push it up to the GitHub repository. In this repository, there are repo actions that will automatically attempt to build the image for the container and push that image to DockerHub if it succeeds. Any non-main branches will be pused to DockerHub under the name of the branch, for example, the branch `geant4.10.5` contains the same container as our `main` but with a more recent version of Geant4:

```diff
$ git diff geant4.10.5 main
diff --git a/Dockerfile b/Dockerfile
index 9627e00..0fb31e8 100644
--- a/Dockerfile
+++ b/Dockerfile
@@ -131,7 +131,7 @@ RUN mkdir xerces-c && cd xerces-c &&\
 #  - G4DIR set to path where Geant4 should be installed
 ###############################################################################
-ENV GEANT4=geant4-10.5-release
+ENV GEANT4=LDMX.10.2.3_v0.4
 LABEL geant4.version="${GEANT4}"
```

And this is enough to have a new container on DockerHub with the Geant4 version 10.5 under the Docker tag `ldmx/dev:geant4.10.5`, so one would use this container by calling `ldmx pull dev geant4.10.5`
