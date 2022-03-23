# Tools and Samples

## Generating Constraints

It is possible to generate a minimal constraint given a `Cube` and a set of `Observation`s.

SPARQL CONSTRUCT queries will be provided in this repository.

## Cube Viewer

Cube Viewer [(Homepage)](https://github.com/zazuko/cube-viewer) is both an app and a reusable component to visualize data cubes based on RDF Cube Schema.

A demo of the app is deployed at [cube-viewer.zazuko.com](https://cube-viewer.zazuko.com).

## Example Cube

An example Cube is specified in [cube.ttl](cube.ttl). The cube provides a constraint in [constraint.ttl](constraint.ttl).

### Validate the cube

<pre class='ednote' title='Work in progress'>
This section is work in progress, the wording and terminology still need some thought.
</pre>

The validation process of the cube can be divided in three different aspects.

1) The cube structure and contents
2) The structure of the observations
3) The integrity of the constraints

We provide a tool to do the actual validations in the repository.

Install the package dependencies: `npm i`

<aside class='example' title='Validate `cube.ttl` by using the constraint in `constraint.ttl`'>
 

```./bin/rdf-cube-schema.js validate cube.ttl constraint.ttl```

</aside>

#### The cube structure and contents
Even though RDF Cube Schema is a very lightweight vocabulary its structure needs to conform to a minimal set of rules to be considered a valid [Cube](#Cube) we provide a very light weight constraint that can be used to check this. The constraint can be found in [validation](https://github.com/zazuko/rdf-cube-schema/tree/master/validation) directory of the repository, the constraint is called [basic-cube-constraint.ttl](https://github.com/zazuko/rdf-cube-schema/tree/master/validation/basic-cube-constraint.ttl)

<aside class='example' title='Validate `cube.ttl` using the constraint in `validation/basic-cube-constraint.ttl`'>
 

```./bin/rdf-cube-schema.js validate cube.ttl validation/basic-cube-constraint.ttl```

</aside>


#### The structure of the observations

When a cube provides an optional observation constraint through the [observationConstaint](#observationConstraint) property this can be tested as well

<aside class='example' title='Validate `cube.ttl` by using the constraint in `constraint.ttl`'>
 

```./bin/rdf-cube-schema.js validate cube.ttl constraint.ttl```

</aside>

<aside class='example' title='Validate a Cube with inline constraints'>
When the cube and constraints are in the same file simply use the same filename twice

```./bin/rdf-cube-schema.js validate completecube.ttl completecube.ttl```

</aside>

#### The integrity of the constraints
If constraints are used to provide guidance for interaction with the cube, e.g. visualizations
it is important that the constraints themselves are confirming to a structure that interaction can deal with

<aside class='example' title='Validate a CubeConstraint with a constraint'>
Here we use the validation to validate the constraint, not the cube

```./bin/rdf-cube-schema.js validate constraint.ttl validation/standalone-constraint-constraint.ttl```

</aside>

The standalone constraint can be extended to meet the specific requirements for the intended interaction.
