# RDF Cube Schema

In this repository we present the *RDF Cube Schema* model.

We describe the model, an elaborate example and scripts to validate observations based on the the constraint (SHACL shape) provided.

We also provide [Best Practice](best-practice.md), and an [Extension for Visualization](https://github.com/zazuko/rdf-cube-schema-viz) related topics.

## Example Cube

An example Cube is specified in [cube.ttl](cube.ttl). The cube provides a constraint in [shape.ttl](shape.ttl).

### Validate the cube

You can validate the cube with a cli tool written in Node.js.

Install the package dependencies: `npm i`

Validate `cube.ttl` by using the SHACL shape in `shape.ttl`: 

```./bin/rdf-cube-schema.js validate cube.ttl shape.ttl```


## Core Schema

The _RDF Cube Schema_ defines a minimal set of classes and properties necessary to represent multi-dimensional arrays of data in [[[rdf11-concepts]]].

The core schema is very simple and almost unconstrained from an RDF perspective. This ensures it can be used in many ways and does not restrict its usefulness due to too rigorous definitions.

Prefix: `cube`
Namespace: `https://cube.link/`

### Classes

* `cube:Cube`: Represents the entry point for a collection of observations, conforming to some common dimensional structure.
* `cube:Observation`: A single observation in the cube, may have one or more associated dimensions.
* `cube:ObservationSet`: A set of observations. One-to-many.
* `cube:Constraint`: Specifies constraints that need to be met on the Cube. Used for metadata and validation. (Optional)

`Cube` and `Observation` are pretty much self-describing. All `Observation`s linked with a `Cube` need to adhere to the same dimensional structure.

![Basic RDF Cube Schema structure](./img/rdf-cube-schema-basic.svg)

An `ObservationSet` is a structure that acts as a container for multiple `Observation`s. It can be used to group any set of `Observation`s, as long as they use the same dimensions. There is on purpose no stronger semantics attached to this set, to make sure it can be used in almost any scenario. A cube can have one or more `ObservationSet`s and an `Observation` can appear in multiple `ObservationSet`s.

### Properties

* `cube:observationSet`: Connects a cube with a set of observations.
* `cube:observationConstraint`: Connects a cube with a constraint for metadata and validation.
* `cube:observation`: Connects a set of observations with a single observation. 
* `cube:observedBy`: Connects an observation with the agent that created the observation. The agent can be a person, organisation, device or software. A description of the method to gather the data could be attached to the agent.

![Observations can be connected to an observer](./img/rdf-cube-schema-observedBy.svg)

### Optional Features

A `Constraint` for a cube. A Constraint is optional but recommended, it is used to:
* Define how data (`Observation`s) in a `Cube` can be validated.
* Add Cube-specific metadata (custom labels, translation to other languages, etc).

### Dimensions

> A dimension is a structure that categorizes facts and measures to enable users to answer business questions. Commonly used dimensions are people, products, place, and time ([Source: Wikidata](https://en.wikipedia.org/wiki/Dimension_(data_warehouse))).

In _RDF Cube Schema_, facts, measures, and categories are all considered a dimension.

All `Observation`s need to provide the same set of dimensions, they cannot be optional. This ensures that cubes can be queried efficiently.

Unlike other RDF vocabularies in that domain, there is no specific class for a dimension. Creating a new _RDF Cube Schema_ dimension would be the same as defining a new [RDF Property](https://www.w3.org/TR/rdf-schema/#ch_property). 

This encourages re-use and makes it much easier to cherrypick on existing RDF properties and use them as dimensions. Obvious examples are temporal properties like `schema:validFrom`, `dcterms:date`, `dcterms:temporal`, etc.

In general, any RDF Property can be considered for describing a dimension, except for heavily constrained properties that might lead to unwanted conclusions (inference) by [reasoners](http://www.w3.org/TR/sparql11-entailment/).

> Note that choosing a particular dimension will have implications. For querying cubes via SPARQL, spatial and temporal dimensions might only be filtered properly if the datatype used (i.e. `xsd:date`, `geo:asWKT`) is supported/optimized by the SPARQL endpoint. This is for example mostly _not_ the case for fragment datatypes like `xsd:gYear` etc.
>
> It has to be ensured that properties are not attached at the wrong level. Spatial dimensions for example are most likely *not* attached to the observation directly but to an instance of a dimension referenced in the observation.

Instances of a dimension can be [RDF literals](https://www.w3.org/TR/rdf11-primer/#section-literal) with [data types](https://www.w3.org/TR/rdf11-concepts/#section-Datatypes) (sometimes called _typed literals_) or IRIs. Only one literal must be attached to each dimension or must point to a single IRI.

Language tagged literals and all other (meta) data should be modeled as  term/concept. For this purpose, [IRI's](https://www.w3.org/TR/rdf11-primer/#section-IRI) should be used and the literal(s) would be appended to that particular instance of a term/concept. This can be done e.g. by using [[[skos-primer]]] (https://www.w3.org/TR/skos-primer/) or schema.org [DefinedTerm](https://schema.org/DefinedTerm). As shown in the following example, a typical cube structure is a combination of dimensions with typed literals attached to the "observation" itself and dimensions that refer to concept groups via IRIs.

![An Observation often combines dimensions of typed literals with dimensions that point to IRIs](./img/rdf-cube-schema-dimensions.svg)

In [[[turtle]]] syntax, the observation above looks like this:

<div class='example'>

```turtle example
<temperature-sensor/cube/observation/20190103T120000055Z> a cube:Observation ;
  cube:observedBy <temperature-sensor> ;
  dh:room <building1/level1/room1> ;
  dh:humidity 75.0 ;
  dh:lowBatteryPower false ;
  dh:temperature 0.0 ;
  dc:date "2019-01-03T12:00:00.055000+00:00"^^xsd:dateTime .
```

</div>

`room1` is an IRI that has labels attached as language-tagged strings. 

```turtle
<building1/level1/room1> a schema:Place ;
  schema:name "Room 1101"@en, "Raum 1101"@de, "Pièce 1101"@fr ;
  schema:inDefinedTermSet <rooms> ;
  schema:containedInPlace <building1/level1> .
```

Nesting of relations can be expressed in a machine readable form as well but is not part of the core RDF Cube Schema.

## Metadata and Validation (Constraint)

_RDF Cube Schema_ supports attaching a "shape", or "constraint" to a cube. The constraints itself are expressed using the [[[shacl]]]

Providing shape and constraints for a cube facilitates the interpretation and validation of the cube for tooling and libraries.

From a pure publishing point of view and according to the [Open World Model](http://linked-data-training.zazuko.com/Ontologies/index.html#14), publishing observations using the core _RDF Cube Schema_ is enough. However, in reality one might want to use the data for other purposes as well, like visualizing it in web applications and other publications. To be useful, such tools might require additional metadata and cubes that adhere to certain constraints.

It is up to the consumer of the data to decide how the shape is used. If provided, it should be possible to validate the observations in the cube with it.

### Shapes

A `cube:Constraint` is also a `sh:NodeShape`. SHACL is used to restrict the cube to a particular structure. The shape presented in this section can be used to validate all `Observation`s in the cube.

If additional restrictions are needed, additional restrictions and shapes could be provided.

The following snipped defines a new shape, it applies to all `cube:Observation`:

```turtle
<example-cube/cube/shape> a sh:NodeShape, cube:Constraint ;
  sh:closed true ;
  sh:property [
    sh:path rdf:type ;
    sh:nodeKind sh:IRI ;
    sh:in ( cube:Observation )
  ]
```

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

### Generating Shapes

It is possible to generate a minimal SHACL shape given a `Cube` and a set of `Observation`s.

SPARQL CONSTRUCT queries will be provided in this repository.

### Types of Dimensions

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

## Existing Work

### RDF Data Cube Vocabulary

The [[[vocab-data-cube]]] is probably the oldest vocabulary in the domain of RDF for representing cubes. The authors of this document used RDF Data Cubes extensively in the past and ran into multiple issues with it.

The authors of this specification are grateful for the work done by the original authors of the RDF Data Cube Vocabulary specification. This work would not have been possible without it and some parts look pretty much like the RDF Data Cube Vocabulary.

It was considered to either clarify or update the RDF Data Cube Vocabulary specification. For the sake of simplicity, it was decided to start from scratch.

#### Issues with RDF Data Cube Vocabulary

* The metadata model is overly complex.
    * Many additional nodes are introduced that make querying the data in the real world overly complex.
    * Generating proper metadata from basic cubes is not easy, which increases complexity for automated pipelines.
* There is a mix of forward- and backward-linking within the metadata model.
* [Follow your nose](https://patterns.dataincubator.org/book/follow-your-nose.html) is often not possible.
* There is more than one way to do it. Different people interpret the spec differently, which makes it very hard to write libraries that consume generic RDF Data Cubes.
* There is a clear focus on [SDMX](https://en.wikipedia.org/wiki/SDMX), which introduces too rigorous restrictions and/or examples for use-cases outside the statistical domain.
* Re-use of dimensions is not very common in the RDF Data Cube vocabulary, that makes it much harder to compare data accross data providers.

There are at least two efforts that extend the RDF Data Cube Vocabulary to address some of its limitations:

* [[[qb4st]]]
* [QB4OLAP](https://github.com/lorenae/qb4olap/wiki)

Both efforts could likely be solved/addressed within the _RDF Cube Schema_ approach, this needs to be validated by interested parties.

### SSN

The [[[vocab-ssn]]] defines a simplified model for describing observations from a sensor in RDF.

The [Observation](https://www.w3.org/TR/vocab-ssn/#SOSAObservation) model is at least inspired by the RDF Data Cube Vocabulary but it is not very useful for use-cases outside of sensor networks.

It should be relatively easy to replace SSN observations with the _RDF Cube Schema_.
