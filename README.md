# Cube Schema

In this repository we develop the *Cube Schema* model.

`@prefix cube: <https://cube.link/>.`

DRAFT: https://zazuko.github.io/cube-link/

## Validation shapes

The [validation](validation) directory contains various SHACL Shapes which can be used to ensure the correctness of datasets, cubes, hierarchies, and other.

They can be retrieved from the web using a URI in the form of `https://cube.link/{VERSION}/shape/{PROFILE}`, where the `{PROFILE}` variable is replaced with any of the shape documents (without `.ttl`) and the `{VERSION}` variable is replaced with any [tag name](https://github.com/zazuko/cube-link/tags) or the word `latest`.
It is recommended to always use a specific version to avoid breaking changes.

For example, to get version 0.0.4 of `standalone-cube-constraint.ttl`, fetch https://cube.link/v0.0.4/shape/standalone-cube-constraint .

Otherwise, to get the latest version, fetch https://cube.link/latest/shape/standalone-cube-constraint instead.

Finally, it is possible to request shapes from a branch or specific commit by building the URI as `/ref/{REF}/shape/...`.
For example, to get the `standalone-cube-constraint` shape from the `main` branch, fetch https://cube.link/ref/main/shape/standalone-cube-constraint and to get it from the commit `a1b2c3d4e5f6`, fetch https://cube.link/ref/a1b2c3d4e5f6/shape/standalone-cube-constraint .

### Published profiles

| Profile                                                                             | Description                                                                                                                               |
|-------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| [standalone-cube-constraint](validation/standalone-cube-constraint.ttl)             | Standard cube profile with minimal metadata                                                                                               |
| [standalone-constraint-constraint](validation/standalone-constraint-constraint.ttl) | Minimal dimensions metadata. Included in `standalone-cube-constraint`                                                                     |
| [profile-opendataswiss](validation/profile-opendataswiss.ttl)                       | Cube metadata profile which follows the [Opendata.swiss Handbook](https://handbook.opendata.swiss/). Extends `standalone-cube-constraint` |
| [profile-opendataswiss-lindas](validation/profile-opendataswiss-lindas.ttl)         | Cube metadata for cubes published to Opendata.swiss from Lindas                                                                           |
| [profile-visualize](validation/profile-visualize.ttl)                               | Cube metadata for cubes published to [Visualize](https://visualize.admin.ch/)                                                             |
| [basic-cube-constraint](validation/basic-cube-constraint.ttl)                       | Minimum cube. This typically isn't used directly                                                                                          |

## How to Contribute

Please open [Issues](https://github.com/zazuko/cube-link/issues) on this repository or provide PRs for contributions.

## Testing

Automatic tests exist to validate cube constraints against maintained profiles, as well as tests
checking the observation against given cube constraints.

### Profile tests

```bash
./test/check-metadata.sh --profile=$PROFILE
```

`$PROFILE` must be the name of one of the profiles in the `validation` directory (without extension).

Test cases are turtle file under `test/$PROFILE` directory.

It is also possible to run only a subset of tests by providing a `--filter` argument. This argument
is a regular expression that is matched against the file name. For example, to run only `basic-cube-constraint`
tests which include the word "undefined":

```bash
./test/check-metadata.sh --profile=basic-cube-constraint --filter=undefined
```

### Observation tests

```bash
./test/check-observations.sh
```

Test cases are turtle file under `test/observations` directory.

This script also supports a `--filter` argument.

Both scripts allow a `--approved` flag to force-approve the current output as valid in case of differences. 
