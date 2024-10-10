# cube-link

## 0.2.3

### Patch Changes

- a41f716: Improve validation of `meta:dimensionRelation`:

  1. Check that upper/lower bound has at most one `dcterms:type`
  2. Check that `meta:relatesTo` is actually a dimension

- 71c3d52: Add an informative section about using [Time Ontology in OWL](https://www.w3.org/TR/owl-time/) for temporal dimensions
- 46133ba: Only use `qudt:hasUnit` in documentation (instead of deprecated `qudt:unit`)
- 641d841: Adding dimension annotations (`meta:annotation`) re https://gitlab.ldbar.ch/bafu/visualize/-/issues/542
- de24a37: Relation vocabulary: added relation types for asymmetrical margin of error

## 0.2.2

### Patch Changes

- d289758: `profile-visualize`: allowed temporal dimensions (`meta:dataKind a time:GeneralDateTimeDescription`) to have ordinal scale type
- 615b1c2: Corrected the URLs in profile-visualize
- 214b479: `standalone-cube-constraint`: `schema:dateModified` now allows both `xsd:dateTime` in addition to `xsd:date` (closes #166)
- 214b479: `profile-visualize`: added `sh:class` to `meta:dataKind` shapes (closes #167)
- 985383e: `standalone-cube-constraint`: Lower severity of `schema:publisher`, `schema:creator` and `schema:contributor` to warning
- 818acbd: `profile-visualize`: Correct wording of scale type constraint
- 5bad04f: `standalone-cube-constraint`: lowered the severity of missing observation to `sh:Warning` (re #168)

## 0.2.1

### Patch Changes

- 9b04f0f: Fix Trifid instance so that it can work with a CommonJS module

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
