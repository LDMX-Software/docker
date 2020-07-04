
## Derivative Description
### What new packages does this derivative add to the development container?
- package1
- package2

### What do you want to tag this container?
`my-tag`
(Check the [Docker Hub](https://hub.docker.com/repository/docker/ldmx/dev) to see what tags are already taken.)

## Check List
- [ ] I successfully built the container using docker
- [ ] I was able to test my container with ldmx-sw using `source ldmx-sw/scripts/ldmx-env.sh . my-tag local`
- [ ] I put my Dockerfile in the `derivatives` directory and named it `Dockerfile.my-tag`
- [ ] I added my container to the list of derivatives to be built in `.github/workflows/derivatives.yml`:
```yml
jobs:
  
  #other derivative containers
  
  my-tag:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build It!
      uses: docker/build-push-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        repository: ldmx/dev
        path: derivatives
        dockerfile: derivatives/Dockerfile.my-tag
        tags: my-tag
```
