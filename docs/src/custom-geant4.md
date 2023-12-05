# Container with Custom Geant4

Geant4 is our main simulation engine and it has a large effect on the products of our simulation samples.
As such, it is very common to compare multiple different versions, patches, and tweaks to Geant4 with our simulation.

There are two different methods for using a custom Geant4. The first one listed is newer but more flexible and is the preferred path forward to prevent the proliferation of ldmx/dev images.

## Locally Build Geant4
With release 4.2.0 of the ldmx/dev image, the entrypoint script now checks the environment variable `LDMX_CUSTOM_GEANT4` for a path to a local installation of Geant4.
This allows the user to override the Geant4 that is within the image with one that available locally. In this way, you can choose whichever version of Geant4 you want,
with whatever code modifications applied, with whatever build instructions you choose.

### Building Your Geant4
You can build your Geant4 in a similar manner as ldmx-sw. It does take much longer to compile than ldmx-sw since it is larger, so be sure to leave enough time for it.
**Remember** You can only run this custom build of Geant4 with whatever container you are building it with, so make sure you are happy with the container version you are using.
```
cd ${LDMX_BASE}
git clone git@github.com:LDMX-Software/geant4.git # or could be mainline Geant4 or an unpacked tar-ball
cd geant4
mkdir build
cd build
ldmx cmake <cmake-options> ..
ldmx make install
```
Now building Geant4 from source has a lot of configuration options that can be used to customize how it is built.
Below are a few that are highlighted for how we use containers and their interaction with the Geant4 build.

- `CMAKE_INSTALL_PREFIX`: This should be set to a path accessible from the container so that the programs within the container can read from and write to this directory. If the geant4 build directory is within `LDMX_BASE` (like it is above), then you could do something like `-DCMAKE_INSTALL_PREFIX=../install` when you run `ldmx cmake` within the build directory.
- `GEANT4_INSTALL_DATADIR`: If you are building a version of Geant4 that has the same data files as the Geant4 version built into the container iamge, then you can tell the Geant4 build to use those data files with this option, saving build time and disk space. This is helpful if (for example) you are just re-building the same version of Geant4 but in Debug mode. You can see where the Geant4 data is within the container with `ldmx 'echo ${G4DATADIR}'` and then use this value `-DGEANT4_INSTALL_DATADIR=/usr/local/share/geant4/data`.

The following are the build options used in when setting up the container and are likely what you want to get started 
- `-DGEANT4_USE_GDML=ON` Enable reading geometries with the GDML markup language which is used in LDMX-sw for all our geometries 
- `-DGEANT4_INSTALL_EXAMPLES=OFF` Don't install the Geant4 example applications 
- `-DGEANT4_USE_OPENGL_X11=ON`  
- `-DGEANT4_MULTITHREADED=OFF` If you are building a version of Geant4 that is multithreaded by default, you will want to disable it with. The dynamic loading used in LDMX-sw will often not work with a multithreaded version of Geant4 

#### Concerns when building different versions of Geant4 than 10.2.3

For most use cases you will be building a modified version of the same release of Geant4 that is used in the container (10.2.3). It is also possible to build and use later versions of Geant4 although this should be done with care. In particular 
- Different Geant4 release versions will require that you rebuild LDMX-sw for use with that version, it will not be sufficient to set the `LDMX_CUSTOM_GEANT4` environment variable and pick up the shared libraries therein
- Recent versions of Geant4 group the electromagnetic processes for each particle into a so-called general process for performance reasons. This means that many features in LDMX-sw that rely on the exact names of processes in Geant4 will not work. You can disable this by inserting something like the following in [RunManager::setupPhysics()](https://github.com/LDMX-Software/SimCore/blob/20d9bcb6d2bad2b99255cf32c1b3f099b26752b0/src/SimCore/RunManager.cxx#L60)
```C++ 
// Make sure to include G4EmParameters if needed
auto electromagneticParameters {G4EmParameters::Instance()};
// Disable the use of G4XXXGeneralProcess,
// i.e. G4GammaGeneralProcess and G4ElectronGeneralProcess
electromagneticParameters->SetGeneralProcessActive(false);
```
- Geant4 relies on being able to locate a set of datasets when running. For builds of 10.2.3, the ones that are present in the container will suffice but other versions may kuneed different versions of these datasets. If you run into issues with this, use `ldmx env` and check that the following environment variables are pointing to the right location 
- `GEANT4_DATA_DIR` should point to `$LDMX_CUSTOM_GEANT4/share/Geant4/data`
- The following environment variables should either be unset or point to the correct location in `GEANT4_DATA_DIR`
  - `G4NEUTRONHPDATA` 
  - `G4LEDATA`
  - `G4LEVELGAMMADATA`
  - `G4RADIOACTIVEDATA`
  - `G4PARTICLEXSDATA`
  - `G4PIIDATA`
  - `G4REALSURFACEDATA`
  - `G4SAIDXSDATA`
  - `G4ABLADATA`
  - `G4INCLDATA`
  - `G4ENSDFSTATEDATA`
- When using CMake, ensure that the right version of Geant4 is picked up at configuration time (i.e. when you run `ldmx cmake`)
  - You can always check the version that is used in a build directory by running `ldmx ccmake .` in the build directory and searching for the Geant4 version variable 
  - If the version is incorrect, you will need to re-configure your build directory. If `cmake` isn't picking up the right Geant4 version by default, ensure that the `CMAKE_PREFIX_PATH` is pointing to your version of Geant4 
- Make sure that your version of Geant4 was built with multithreading disabled 
### Running with your Geant4
Just like with ldmx-sw, you can only run a specific build of Geant4 in the same container that you used to build it.
```
ldmx setenv LDMX_CUSTOM_GEANT4=/path/to/geant4/install
```
If you followed the procedure above, the Geant4 install will be located at `${LDMX_BASE}/geant4/install` and you can use
this in the `setenv` command.
```
ldmx setenv LDMX_CUSTOM_GEANT4=${LDMX_BASE}/geant4/install
```

## Remote Build
You could also build your custom version of Geant4 into the image itself.
The container is allowed to build (almost) any release of Geant4, pulling either from the [official Geant4 repository](https://github.com/Geant4/geant4) or pulling from [LDMX's fork](https://github.com/LDMX-Software/geant4) if "LDMX" appears in the tag name requested.

Most of the newer versions of Geant4 can be built the same as the current standard [LDMX.10.2.3_v0.4](https://github.com/LDMX-Software/geant4/releases/tag/LDMX.10.2.3_v0.4), so to change the tag that you want to use in the container you simply need to change the `GEANT4` parameter in the Dockerfile.

```
...a bunch of crap...
ENV GEANT4=LDMX.10.2.3_v0.4 #CHANGE ME TO YOUR TAG NAME
... other crap ...
```

Changing this parameter _could_ be all you need, but if the build is not completing properly, you may need to change the `RUN` command that actually builds Geant4.

### Building the Image
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
