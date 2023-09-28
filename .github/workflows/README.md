# GitHub Workflows for Development Image

The workflow is split into three parts.
1. Build: In separate and parallel jobs, build the image for the different architectures
    we want to support. Push the resulting image (if successfully built) to DockerHub only
    using its sha256 digest.
2. Merge: Create a manifest for the images built earlier that packages the different
    architectures together into one tag. Container managers (like docker and singularity)
    will then deduce from this manifest which image they should pull for the architecture
    they are running on.
3. Test: Check that ldmx-sw can compile and pass its tests at various versions for the
    built image.

We only test after a successful build so, if the tests fail, users can pull the image and
debug why the tests are failing locally.

## ldmx-sw Test Versions
The CI can only test a finite number of versions of ldmx-sw - in general, we'd like
to make sure the past few minor versions are supported (with the possibility of interop
patches) by the new container image build while also enabling support for the newest ldmx-sw.
This means we _manually_ write the `ldmx_sw_branch` for the CI to test following the rules
- Test minimum version supported (currently set at `v3.0.0`)
- Test newest developments of ldmx-sw (`trunk`)
- Test highest patch-number for each minor version in between (`v3.0.2`, `v3.1.13`, `v3.2.12`)
- Test additional releases specifically related to the container image
  - For example `v3.2.4` was the last release before necessary updates were made to support
    the newer GCC version in v4 images.

## Legacy Interop
For some past versions of ldmx-sw, we need to modify the code slightly 
in order for it to be able to be built by the newer containers. For
this reason, we have a set of interop scripts (the `.github/interop` directory).
If there is a directory corresponding to the version being tested, then the
CI will run the scripts in that directory before attempting to build
and install ldmx-sw.

If there are interop patches, we assume that the testing is also
not functional so neither the test program nor a test simulation
are run.

## GitHub Actions Runner
The image builds take a really long time since we are building many large
packages from scratch and sometimes emulating a different architecture than
the one doing the image building. For this reason, we needed to move to
a self-hosted runner solution which is documented on the next page.
