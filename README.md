# Cube Schema

In this repository we develop the *Cube Schema* model.

`@prefix cube: <https://cube.link/>.`

DRAFT: https://zazuko.github.io/cube-link/

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
