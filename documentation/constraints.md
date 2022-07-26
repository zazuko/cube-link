# Cube Schema: Constraints

From a pure publishing point of view and according to the [Open World Model](http://linked-data-training.zazuko.com/Ontologies/index.html#14), publishing observations using the core _Cube Schema_ is enough. However, in reality, one might want to use the data for other purposes as well, like visualizing it in web applications and other publications. To be useful, such tools might require additional metadata and cubes that adhere to certain constraints.

_Cube Schema_ supports attaching a "constraint" to a cube. The constraints themselves are expressed using the [[[shacl]]]

Providing constraints for a cube facilitates the documentation, interpretation, and validation of the cube for tooling and libraries. There is only one constraint per cube allowed, this results in a very low overhead for the documentation, the cube and observations do not need any documentation on the data level.



It is up to the consumer of the data to decide how the constraint is used. If provided, it should be possible to validate the observations in the cube with it.

## Constraints

### Cube Constraints  {#cubeconstraints}

A [cube:Constraint](#Constraint) is also a `sh:NodeShape`. [[[shacl]]] is used to restrict the cube to a particular structure. The Constraint presented in this section can be used to validate all `Observation`s in the cube.

If additional restrictions are needed, additional restrictions expressed as [[[shacl]]] can be provided.

The following snippet defines a new constraint, it applies to all `cube:Observation`:

<aside class='example'>

```turtle
<example-cube/cube/constraint> a sh:NodeShape, cube:Constraint ;
  sh:closed true ;
  sh:property [
    sh:path rdf:type ;
    sh:nodeKind sh:IRI ;
    sh:in ( cube:Observation )
  ]
```

</aside>

### Dimension Constraints  {#dimensionconstraints}

Dimension Constraints are linked to Cube Constraints through the `sh:property` property, the Dimension constraints uses the [[[shacl]]] vocabulary to express the constraints for the specific dimension.

#### sh:path

The dimension/property is referenced using `sh:path`. The value of the path must be a single value and not an RDF list.

#### additional constraints
Additional constraints can be added according to the SHACL specification, for example, data types, min/max values, etc.
The following snippet defines a dimension (property) `dc:date` with a literal value (`xsd:dateTime`):

<aside class='example' title='Additional constraints on a dimension'>

```turtle
[
  schema:name "Date and Time"@en, "Datum und Zeit"@de, "Date et heure"@fr; # optional, label of the vocab can be used
  sh:path dc:date ;
  sh:datatype xsd:dateTime ;
  sh:minCount 1 ;
  sh:maxCount 1 ;
]
```
</aside>

#### Usage of code lists

Dimensions that point to objects like code lists (i.e taxonomies represented in vocabularies like [[[skos-primer]]]) can be expressed as well:

<aside class='example' title='Using code lists on  a dimension'>

```turtle
[
  schema:name "Room"@en, "Raum"@de , "Pièce"@fr ;
  sh:path dh:room ;
  sh:maxCount 1 ;
  sh:in ( <building1/level1/room1> <building1/level1/room2> ) ;
]
```

</aside>

Dimensions can have further types, which are not defined by this vocabulary to support other Dimensions (e.g. Precision, Statistical Measures) or for additional Attributes to filter on, which are not part of the key to defining a [`cube:KeyDimension`](#KeyDimension).

