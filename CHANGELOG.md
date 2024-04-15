# cube-link

## 0.2.0

### Minor Changes

- 1c2205e: Include `standalone-constraint-constraint` in `standalone-cube-constraint`

### Patch Changes

- 3f40fd5: Validating RDF Lists should now work with long lists of any size
- 4645d09: Visualize validation profile (closes #114)
- 9faf4fb: Validation profiles: switch to `sh:xone` where appropriate
- d7d3256: Added validation profile for opendata.swiss (closes #118)

## 0.1.5

### Patch Changes

- dd52484: Documentation of new cube validation tools

## 0.1.4

### Patch Changes

- 81b209f: `standalone-cube-constraint`: Allow `schema:contactPoint` to be a blank node
- 9d28874: Support git refs when serving shapes from Trifid

## 0.1.3

### Patch Changes

- 86a40d7: In the CI, make sure to pull the Git repository with the token, to make sure it is able to trigger tags GitHub Actions workflows
- 7777e94: Generate Docker tags and labels using docker/metadata-action

## 0.1.2

### Patch Changes

- 6b78238: Bumping version only to trigger CI

## 0.1.1

### Patch Changes

- 09e2f3d: Forward profiles directly from GitHub

## 0.1.0

### Minor Changes

- 6d65dca: Adjust shape base to match how they are deployed (re #94)

### Patch Changes

- a38baff: Fixes the problem that validation script did not correctly target cube observations
