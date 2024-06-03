# Tools and Samples

## Generating Constraints

It is possible to generate a minimal constraint given a `Cube` and a set of `Observation`s.
More information is available in the `barnard59-cube` [commands](https://github.com/zazuko/barnard59/tree/master/packages/cube#commands) documentation.

## Cube Viewer

Cube Viewer [(Homepage)](https://github.com/zazuko/cube-viewer) is both an app and a reusable component to visualize data cubes based on Cube Schema.

A demo of the app is deployed at [cube-viewer.zazuko.com](https://cube-viewer.zazuko.com).

## Validating Cubes

An example Cube is specified in [cube.ttl](cube.ttl). The cube provides a constraint in [constraint.ttl](constraint.ttl).

The validation process of the cube can be divided into three different aspects.

1) The cube structure and contents
2) The structure of the observations
3) The integrity of the constraints

The node package `barnard59-cube` includes [commands](https://github.com/zazuko/barnard59/tree/master/packages/cube#commands) to validate cubes and their constraints. Validation commands can be used with SHACL shapes defined [here](https://github.com/zazuko/cube-link/tree/main/validation).

To use, install `barnard59` CLI and the `barnard59-cube` package globally: 

```bash
npm install -g barnard59 barnard59-cube
```

Validation commands provide [SHACL validation reports](https://www.w3.org/TR/shacl/#validation-report) in case of violations:

<aside class='example' title='Validate `cube.ttl` by using the constraint in `constraint.ttl`'>
 

```bash
 cat cube.ttl 
 | barnard59 cube check-observations --constraint constraint.ttl
```

</aside>

To get a human-readable summary of the report, chain another command, available with the `barnard59-shacl` package:

<aside class='example' title='Validation with summary of report'>
 

```bash
 cat cube.ttl 
 | barnard59 cube check-observations --constraint constraint.ttl
 | barnard59 shacl report-summary 
```

</aside>


#### The cube structure and contents
Even though Cube Schema is a very lightweight vocabulary, there is a minimal set of rules to make a valid [Cube](#Cube). We provide a [basic cube constraint](https://cube.link/latest/shape/basic-cube-constraint) to check this (notice that input includes both cube and constraint).

<aside class='example' title='Validate cube using `basic-cube-constraint`'>
 

```bash
cat cube.ttl constraint.ttl | barnard59 cube check-metadata /
    --profile https://cube.link/latest/shape/basic-cube-constraint
```

</aside>


#### The structure of the observations

When a cube provides an optional observation constraint through the [observationConstaint](#observationConstraint) property, this can be tested as well.

The constraint should be a SHACL shape but it's expected to not have any [target declaration](https://www.w3.org/TR/shacl/#targets).
The validation tool takes care of making all the observations a target for the constraint.

<aside class='example' title='Validate `cube.ttl` by using the constraint in `constraint.ttl`'>
 

```bash
 cat cube.ttl | barnard59 cube check-observations --constraint constraint.ttl
```

</aside>

<aside class='example' title='Validate a Cube with inline constraints'>
When the cube and constraints are in the same file simply use the same filename twice

```bash
 cat completecube.ttl | barnard59 cube check-observations --constraint completecube.ttl
```

</aside>

Notice that a single file is suitable only for small cubes: the `check-observations` command can process big cubes splitting the input into chunks but the constraint file is expected to fit in memory.

Further options and details are described in the [documentation](https://github.com/zazuko/barnard59/tree/master/packages/cube#check-observations). 

#### The integrity of the constraints
If constraints are used to provide guidance for interaction with the cube (e.g. visualizations), the constraints themselves should conform to a structure that interaction can deal with.

<aside class='example' title='Validate a CubeConstraint with a constraint'>
Here we use the command to validate the constraint, not the cube

```bash
cat constraint.ttl | barnard59 cube check-metadata /
    --profile https://cube.link/latest/shape/standalone-constraint-constraint
```

</aside>

The standalone constraint can be extended to meet the specific requirements for the intended interaction.
