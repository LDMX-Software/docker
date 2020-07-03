## Derivatives

Derivatives of the development container are useful for incorporating packages that aren't inside of the minimal development container.
The first example of this is `uproot`.
Several collaborators use `uproot` along with the libraries compiled inside the development container to do analyses.
This means that those collaborators **need** to have `uproot` inside of the container.

This is where the line is drawn.
Derivative containers should only be made when there is a need for an extra package **at the same time** as using libraries compiled in ldmx-sw.

### Current List of Derivatives
- uproot
