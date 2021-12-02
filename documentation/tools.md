# Tools and Samples

## Generating Constraints

It is possible to generate a minimal constraint given a `Cube` and a set of `Observation`s.

SPARQL CONSTRUCT queries will be provided in this repository.

## Example Cube

An example Cube is specified in [cube.ttl](cube.ttl). The cube provides a constraint in [constraint.ttl](constraint.ttl).

### Validate the cube

You can validate the cube with a cli tool written in Node.js.

Install the package dependencies: `npm i`

Validate `cube.ttl` by using the constraint in `constraint.ttl`: 

```./bin/rdf-cube-schema.js validate cube.ttl constraint.ttl```
