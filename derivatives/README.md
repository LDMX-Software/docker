## Derivatives

Derivatives of the development container are useful for incorporating packages that aren't inside of the minimal development container.
The first example of this is `uproot`.
Several collaborators use `uproot` along with the libraries compiled inside the development container to do analyses.
This means that those collaborators **need** to have `uproot` inside of the container.

### Current List of Derivatives and the Corresponding Tag
To use a given derivative tag, you need to pass it to the ldmx-sw environment script:
```bash
source ldmx-sw/scripts/ldmx-env.sh . tag
```

| Tag | Extra Packages |
|---|---|
|`uproot`|uproot|
