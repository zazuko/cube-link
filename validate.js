const clownface = require('clownface')
const rdf = require('rdf-ext')
const SHACLValidator = require('rdf-validate-shacl')
const namespace = require('@rdfjs/namespace')

const ns = {
  cube: namespace('https://cube.link/'),
  rdf: namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#'),
  sh: namespace('http://www.w3.org/ns/shacl#')
}

/*

Validates the given cube given as a Dataset with the shape given as a Dataset.
The cube and shape are connected on the fly with triples in the following pattern:

_:b1 a sh:NodeShape;
  sh:targetNode ?cube;
  sh:property [
    sh:node ?observationShape; # from ?cube cube:observationConstraint ?observationShape
    sh:path (cube:observationSet cube:observation);
  ].

*/
async function validateCube (cube, shape, factory = rdf) {
  const cubeRoot = clownface({ dataset: cube, term: ns.cube.Cube }).in(ns.rdf.type)

  if (!cubeRoot.term) {
    throw new Error('could not find a unique cube in cube dataset')
  }

  clownface({ dataset: shape, term: rdf.blankNode() })
    .addOut(ns.sh.targetNode, cubeRoot)
    .addOut(ns.sh.property, null, property => {
      property.addOut(ns.sh.node, cubeRoot.out(ns.cube.observationConstraint))
      property.addList(ns.sh.path, [ns.cube.observationSet, ns.cube.observation])
    })

  const validator = new SHACLValidator(shape, { factory })

  return validator.validate(cube)
}

module.exports = {
  validateCube
}
