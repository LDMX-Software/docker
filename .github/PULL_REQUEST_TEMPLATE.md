
I am adding a new package to the container, here are the details.

### What new packages does this PR add to the development container?
- package1
- package2

## Check List
- [ ] I successfully built the container using docker
```
# outline of container build instructions
cd docker
git checkout my-updates
docker build . -t ldmx/local:temp-tag
```
- [ ] I was able to build ldmx-sw using this new container build
```
# outline of build instructions
ldmx-container-pull local temp-tag
cd ldmx-sw
mkdir build
cd build
ldmx cmake ..
ldmx make install
```
- [ ] I was able to test run a small simulation and reconstruction inside this container
```
# outline of test instructions
cd $LDMX_BASE/ldmx-sw/build
ldmx ctest
cd ..
for c in `ls ldmx-sw/*/test/*.py`; ldmx fire $c; done
```
- [ ] I was able to successfully use the new packages. Explain what you did to test them below:

