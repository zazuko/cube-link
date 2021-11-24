# Tools and Samples

## Generating Shapes

It is possible to generate a minimal SHACL shape given a `Cube` and a set of `Observation`s.

SPARQL CONSTRUCT queries will be provided in this repository.

## Example Cube

An example Cube is specified in [cube.ttl](cube.ttl). The cube provides a constraint in [shape.ttl](shape.ttl).

### Validate the cube

You can validate the cube with a cli tool written in Node.js.

Install the package dependencies: `npm i`

Validate `cube.ttl` by using the SHACL shape in `shape.ttl`: 

```./bin/rdf-cube-schema.js validate cube.ttl shape.ttl```
