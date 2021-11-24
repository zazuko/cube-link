# RDF Cube Schema : Constraints

From a pure publishing point of view and according to the [Open World Model](http://linked-data-training.zazuko.com/Ontologies/index.html#14), publishing observations using the core _RDF Cube Schema_ is enough. However, in reality one might want to use the data for other purposes as well, like visualizing it in web applications and other publications. To be useful, such tools might require additional metadata and cubes that adhere to certain constraints.

_RDF Cube Schema_ supports attaching a "constraint" to a cube. The constraints itself are expressed using the [[[shacl]]]

Providing constraints for a cube facilitates the documentation, interpretation and validation of the cube for tooling and libraries. There is only one constraint per cube allowed, this results in a very low overhead for the documentation, the cube and observations do not need any documentation on data level.



It is up to the consumer of the data to decide how the shape is used. If provided, it should be possible to validate the observations in the cube with it.

## Constraints

A [cube:Constraint](#Constraint) is also a `sh:NodeShape`. [[[shacl]]] is used to restrict the cube to a particular structure. The Constraint presented in this section can be used to validate all `Observation`s in the cube.

If additional restrictions are needed, additional restrictions expressed as [[[shacl]]] can be provided.

The following snipped defines a new shape, it applies to all `cube:Observation`:

<aside class='example'>

```turtle
<example-cube/cube/shape> a sh:NodeShape, cube:Constraint ;
  sh:closed true ;
  sh:property [
    sh:path rdf:type ;
    sh:nodeKind sh:IRI ;
    sh:in ( cube:Observation )
  ]
```

</aside>

For each dimension (facts, measures, and categories) an additional `sh:property` should be provided. The dimension/property is referenced using `sh:path`. The value of the path must be a single value and not an RDF list.

Additional metadata like labels can be attached to the `sh:property` node.

Additional constraints can be added according to the SHACL specification, for example datatypes, min/max values, etc.
The following snippet defines a dimension (property) `dc:date` with a literal value (`xsd:dateTime`):

```turtle
[
  schema:name "Date and Time"@en, "Datum und Zeit"@de, "Date et heure"@fr; # optional, label of the vocab can be used
  sh:path dc:date ;
  sh:datatype xsd:dateTime ;
  sh:minCount 1 ;
  sh:maxCount 1 ;
]
```

Dimensions that point to objects like code lists (i.e taxonomies represented in vocabularies like [SKOS](https://www.w3.org/TR/skos-primer/)) can be expressed as well:

```turtle
[
  schema:name "Room"@en, "Raum"@de , "Pièce"@fr ;
  sh:path dh:room ;
  sh:maxCount 1 ;
  sh:in ( <building1/level1/room1> <building1/level1/room2> ) ;
]
```

SHACL also provides properties that are not used for validation purposes like `shacl:order`. This can be used to indicate the relative order of the dimension, for use in visualizations. It should be used according to [the specification](https://www.w3.org/TR/shacl/#order) by using ascending order, for example so that properties with smaller order are placed above (or to the left) of properties with larger order. 

## Types of Dimensions

To be able to understand the nature of a dimension we can type the dimension in the constraints. In general we have at least two mandatory types per cube, the `cube:MeasureDimension` and the `cube:KeyDimension`. Whereas the `cube:MeasureDimension` does flag at least one dimension, but potentially multiples which is the actually measurement, or statistical count attached to an observation. The `KeyDimension` tags one or multiple dimensions which are together uniquely identifying an observation. You can think of them as the *Key* in a realational database.

```turtle
<temperature-sensor/cube/shape> a sh:NodeShape, cube:Constraint ;
  sh:property [
    sh:path rdf:type ;
    sh:nodeKind sh:IRI ;
    sh:in ( cube:Observation )
  ], [ a cube:KeyDimension ; # Dimension is part of the Key
    sh:path cube:observedBy ;
    sh:nodeKind sh:IRI ;
    sh:in ( <temperature-sensor> )
  ], [ a cube:KeyDimension ; # Dimension is part of the Key
    schema:name "Date and Time"@en, "Datum und Zeit"@de, "Date et heure"@fr;
    sh:path dc:date ;
    sh:datatype xsd:dateTime ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
    qudt:scaleType qudt:IntervalScale ;
  ], [ a cube:MeasureDimension ; # The measurement of this observation.
    schema:name "Humidity"@en, "Feuchtigkeit"@de, "Humidité"@fr ;
    sh:path dh:humidity ;
    sh:datatype xsd:decimal ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
    sh:minInclusive 0 ;
    sh:maxInclusive 100 ;
    qudt:scaleType qudt:IntervalScale ;
  ].
```

Finally to be able to distinguish of Dimensions which are defined inside a Cube from Dimensions which are used in multiple cubes, we have the type of `cube:SharedDimensions`. Every dimension except the ones typed as `cube:MeasureDimension` can be a `cube:SharedDimension`.
```turtle
[ a cube:KeyDimension, cube:SharedDimension ;
    schema:name "Canton"@en, "Kanton"@de, "Canton"@fr;
    sh:path example:canton ;
    qudt:scaleType qudt:NominalScale ;
  ].
```

Dimensions can have further types, which are not defined by this vocabulary to support other Dimensions (e.g. Precision, Statistical Measures) or for additional Attributes to filter on, which are not part of the key to define a `cube:KeyDimension`.

