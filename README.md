# rdf-cube-schema


## Validate the cube

You can validate the cube with a cli tool written in Node.js.

Install the package dependencies: `npm i`

Validate `cube.ttl` by using the SHACL shape in `shape.ttl`: 

    ./bin/rdf-cube-schema.js validate cube.ttl shape.ttl