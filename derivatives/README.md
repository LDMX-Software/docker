## Derivatives

Derivatives of the development container are useful for incorporating packages that aren't inside of the minimal development container.

### Current List of Derivatives and the Corresponding Tag
To use a given derivative tag, you need to pass it to the ldmx-sw environment script:
```bash
source ldmx-sw/scripts/ldmx-env.sh . tag
```

| Tag | Extra Packages |
|---|---|
|`pytools`|uproot,rootpy,numpy,matplotlib,PyROOT in python3|
|`py2tools`|uproot,numpy,matplotlib,PyROOT in python2|

### Documentation
After developing a derivative dockerfile (i.e. making sure it builds successfully and runs the way you want it to),
you can open a branch on this repository with your Dockerfile.
Follow the structure laid out by the first derivative containter: `uproot`:

- Decide on a short, memorable tag for your derivative container (e.g. my-tag)
- Name your Dockerfile accordingly (e.g. Dockerfile.my-tag) and put it in the `derivatives` directory
- Update the GitHub action by copying the `uproot` stuff and replacing `uproot` with `my-tag`, e.g.
```yml
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
