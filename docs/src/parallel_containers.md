# Using Parallel Containers
Sometimes users wish to compare the behavior of multiple containers without changing the source code of ldmx-sw (or a related repository) very much if at all.
This page documents how to use two (or more) containers in parallel.

Normally, when users switch containers, they need to full re-build after fully cleaning out all of the generated files (usually with `ldmx clean src`).
This method avoids this connection between a full re-build and switching containers at the cost of extra complexity.

The best way to document this is by outlining an example; however, please note that this can easily be expanded to any number of containers you wish
(and could be done with software that is not necessarily ldmx-sw).
Let's call the two containers we wish to use `alice` and `bob`, 
both of which are already built (i.e. they are seen in the list returned by `ldmx list dev`).

### 1. Clean Up Environment
```
cd ~/ldmx/ldmx-sw # go to ldmx-sw
ldmx clean src # make sure clean build
```

### 2. Build for Both Containers
```
ldmx use dev alice # going to build with alice first
ldmx cmake -B alice/build -S . -DCMAKE_INSTALL_PREFIX=alice/install
cd alice/build
ldmx make install
cd ../..
ldmx use dev bob # now lets build with bob
ldmx cmake -B bob/build -S . -DCMAKE_INSTALL_PREFIX=bob/install
cd bob/build
ldmx make install
cd ../..
```

### 3. Run with a container
The container looks at a specific path for libraries to link and executables to run
that were built by the user within the container. In current images (based on version 3
or newer), this path is `${LDMX_BASE}/ldmx-sw/install`. **Note**: Later images may move
this path to `${LDMX_BASE}/.container-install` or similar, in which case, the path that
you symlink the install to will change.
```
# I want to run alice so I need its install in the location where
# the container looks when it runs (i.e. ldmx-sw/install)
ln -sf alice/install install
ldmx use dev alice
ldmx fire # runs ldmx-sw compiled with alice
ln -sf bob/install install
ldmx use dev bob
ldmx fire # runs ldmx-sw compiled with bob
```
