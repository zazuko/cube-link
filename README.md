# Cube Schema

In this repository we develop the *Cube Schema* model.

`@prefix cube: <https://cube.link/>.`

DRAFT: https://zazuko.github.io/cube-link/

## Validation shapes

The [validation](validation) directory contains various SHACL Shapes which can be used to ensure the correctness of datasets, cubes, hierarchies, and other.

They can be retrieved from the web using an URI in the form of `https://cube.link/{VERSION}/shape/{CONSTRAINT}`, where the `{CONSTRAINT}` variable is replaced with any of the shape documents (without `.ttl`) and the `{VERSION}` variable is replaced with any [tag name](https://github.com/zazuko/cube-link/tags) or the word `latest`. It is recommended to always use specific version to avoid breaking changes.

For example, to get version 0.0.4 of `standalone-cube-constraint.ttl`, fetch https://cube.link/v0.0.4/shape/standalone-cube-constraint

Otherwise, to get the latest version, fetch https://cube.link/latest/shape/standalone-cube-constraint instead

## How to Contribute

Please open [Issues](https://github.com/zazuko/cube-link/issues) on this repository or provide PRs for contributions.
