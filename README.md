# docker
Docker build context for developing and running ldmx-sw.

Docker has developed a [GitHub action](https://github.com/marketplace/actions/build-and-push-docker-images) that can automatically build docker images and push them to dockerhub. 
I hope to use this action so that we can easily update any images that we wish.

In the long run, we could setup a workflow where a new production running docker image is generated with any commits or releases on the master branch.

- Helpful stack overflow: https://stackoverflow.com/a/49848507
- Docker Action: https://github.com/marketplace/actions/build-and-push-docker-images
