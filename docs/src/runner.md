# GitHub and Self-Hosted Runners

We've run into the main obstacle with using the free, GitHub-hosted runners - 
a single job is required to run for less than six hours. Instead of attempting
to go through the difficult process of partitioning the image build into multiple
jobs that each take less than six hours, we've chosen to attach a self-hosted
runner to this repository which allows us to expand the time limit up to 35 days
as we see fit. This document outlines the motivations for this change, how this
was implemented, how to maintain the current self-hosted runner, and how to
revert this change if desired.

## Motivation
As mentioned above, the build step for this build context lasts longer than six
hours for non-native architecture builds. Most (if not all) of GitHub's runners
have the amd64 architecture, but we desire to also build an image for the arm64
architecture since several of our collaborators have arm-based laptops they are
working on (most prominently, Apple's M series). A build for the native architecture
takes roughly three hours while a build for a non-native architecture, which
requires emulation with `qemu`, takes about ten times as long (about 30 hours).
This emulation build is well over the six hour time limit of GitHub runners and
would require some serious development of the Dockerfile and build process in
order to cut it up into sub-jobs each of which were a maximum of six hours long
(especially since some build _steps_ were taking longer than six hours).

Putting all this information together, a natural choice was to move the building
of these images to a self-hosted runner in order to (1) support more architectures
besides amd64, (2) avoid an intricate (and potentially impossible) redesign of
the build process, and (3) expand the job time limit to include a slower emulation
build.

## Implementation
While individual builds take a very long time, we do not do a full build of the
image very frequently. In fact, besides the OS upgrade, there hasn't been a change
in dependencies for months at a time. Thus, we really don't require a highly
performing set of runners. In reality, we simply need a single machine that can
host a handful of runners to each build a single architecture image one at a time
in a single-threaded, single-core manner.

Once we enter the space of self-hosted runners, there is a lot of room to explore
different customization options. The GitHub runner application runs as a user on
the machine it is launched from so we could highly-specialize the environment of
that machine so the actions it performs are more efficient. I chose to _not_ go
this route because I am worried about the maintanability of self-hosted runners
for a relatively small collaboration like LDMX. For this reason, I chose to attempt
to mimic a GitHub runner as much as possible in order to reduce the number of changes
necessary to the workflow definition - allowing future LDMX collaborators to stop
using self-hosted runners if they want or need to.

### Workflow Definition
In the end, I needed to change the [workflow definition](../.github/workflows/ci.yml)
in five ways.

1. `runs-on: self-hosted` - tell GitHub to use the registered self-hosted runners rather than their own
2. `timeout-minutes: 43200` - increase job time limit to 30 days to allow for emulation build to complete
3. Add `type=local` cache at a known location within the runner filesystem
4. Remove `retention-days` limit since the emulation build may take many days
5. Add the `linux/arm64` architecture to the list of platforms to build on

The local cache is probably the most complicated piece of the puzzle and
I will not attempt to explain it here since I barely understand it myself.
For future workflow developers, I'd point you to Docker's
[cache storage backends](https://docs.docker.com/build/cache/backends/)
and 
[cache management with GitHub actions](https://docs.docker.com/build/ci/github-actions/cache/)
documentation.
The current implementation stores a cache of the layers created during
the build process on the local filesystem (i.e. on the disk of the runner).
These layers need to be separated by platform so that the different architectures
do not interfere with each other.

### Self-Hosted Runner
GitHub has good documentation on 
[Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
that you should look at if you want to learn more.
This section is merely here to document how the runners for this repository
were configured.

First, I should note that I put all of this setup inside a Virtual Machine on
the computer I was using in order to attempt to keep it isolated. This is meant
to provide some small amount of security since GitHub points out that a malicious
actor could fork this repository and 
[run arbitrary code on the machine by making a PR](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners#self-hosted-runner-security)
.[^1]

- VM with 2 cores and ~3/4 of the memory of the machine
- Ubuntu 22.04 Minimal Server
- Install OpenSSH so we can connect to the VM from the host machine
- Have `github` be the username (so the home directory corresponds to the directory in the workflow)
- Make sure `tmux` is installed so we can startup the runner and detach
- Get the IP of the VM with `hostname -I` so we can SSH into it from the host
  - I update the host's SSH config to give a name to these IP addresses so its easier to remember how to connect.
  - From here on, I am just SSHing to the VM from the host. This makes it easier to copy in commands copied from the guides linked below.  
- [Install docker engine](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- Follow [post-install instructions](https://docs.docker.com/engine/install/linux-postinstall/) to allow `docker` to be run by users
- Follow [Add a Self-Hosted Runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)
  treating _the VM_ as the runner and _not_ the host
  - add the `UMN` label to the runners during config so LDMX knows where they are
- Repeat these steps for _each_ of the runners (isolating the runners from the host and each other)
  - We did attempt to have the runners share a VM and a layer cache, but this was
    causing issues when two jobs were trying to read from the same layer cache and one
    was completing before the other [LDMX-Software/docker Issue #69](https://github.com/LDMX-Software/docker/issues/69)

I'd like to emphasize how simple this procedure was.
GitHub has put a good amount of effort into making Self-Hosted runners easy to connect,
so I'd encourage other LDMX institutions to contribute a node if the UMN one goes down.

[^1]: Besides this isolation step, I further isolated this node by working with our
IT department to take control of the node - separating it from our distributed filesystem
hosting data as well as our login infrastructure.

## Maintenance
The maintenance for this runner is also relatively simple. Besides the obvious steps of
checking to make sure that it is up and running on a periodic basis, someone at UMN[^2]
should log into the node periodically to check how much disk space is available within
the VM. This needs to be done because I have implemented the workflow and the runner to
**not** delete the layer cache **ever**. This is done because we do not build the image
very frequently and so we'd happily keep pre-built layers for months or longer if it
means adding a new layer on at the end will build faster.

A full build of the image from scratch takes ~1.8GB of cache and we have allocated ~70GB
to the cache inside the VM. This should be enough for the foreseeable future.

Future improvements to this infrastructure could include adding a workflow whose job
is to periodically connect to the runner, check the disk space, and - if the disk space
is lacking space - attempt to clean out some layers that aren't likely to be used again.
`docker buildx` has cache maintenance tools that we could leverage **if** we specialize
the build action more by having the runner be configured with pre-built docker builders
instead of using the `setup-buildx` action as a part of our workflow. I chose to _not_ go
this route so that it is easier to revert back to GitHub building were persisting docker
builders between workflow runs is not possible.

[^2]: For UMN folks, the username/password for the node and the VM within it are written
down in the room the physical node is in. The node is currently in PAN 424 on the central
table.

## Revert
This is a somewhat large infrastructure change, so I made the concious choice to leave
reversion easy and accessible. If a self-hosted runner becomes infeasible or GitHub changes its policies
to allow longer job run times (perhaps through some scheme of total job run time limit
rather than individual job run time limit), we can go back to GitHub-hosted runners for
the building by updating the workflow.

1. `runs-on: ubuntu-latest` - use GitHub's ubuntu-latest runners
2. remove `timeout-minutes: 43200` which will drop the time limit back to whatever GitHub imposes (6hrs right now)
3. remove caching parameters (GitHub's caching system is too short-lived and too small at the free tier to be useful for our builds)
5. remove the `linux/arm64` architecture from the list of platforms to build on (unless GitHub allows jobs a longer run time)
    - Images can still be built for the arm architecture, but they would need to happen manually by the user with that computer
      or by someone willing to run the emulation and figure out how to update the manifest for an image tag
