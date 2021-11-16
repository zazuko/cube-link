# RDF Cube Schema: Visualization Extensions

This is work in progress for extending the [RDF Cube Schema](https://github.com/zazuko/rdf-cube-schema) with additional metadata that can be used for better default-visualizations of RDF cubes.

## External Vocabularies

| PREFIX | IRI | Description |
| --- | --- | --- |
| cube | https://cube.link | The underlying RDF Cube Schema on which this extension is based on.|
| schema | [http://schema.org](http://schema.org) | To describe basic properties. |
| shacl | [http://www.w3.org/ns/shacl](https://www.w3.org/TR/shacl/) | Inherited from the RDF Cube Schema for constratins. |
| qudt | [http://qudt.org/vocab/](http://www.qudt.org/doc/DOC_SCHEMA-QUDT.html) | Describe scale of mesures. |
| unit | [http://qudt.org/vocab/unit/](http://www.qudt.org/doc/DOC_VOCAB-UNITS.html) | Describes units on values. |
| time | [http://www.w3.org/2006/time#](https://www.w3.org/TR/owl-time/) | A time description ontology. |

## Cube Description
To add the title and a short description of the cube the properties `schema:name` and `schema:description` are used respectively directly on the `cube:Cube` Class.

## Dimension Description

### Name and Description
The name and description of a dimension are represented in the [Cube Constraint per Dimension](https://github.com/zazuko/rdf-cube-schema#metadata-and-validation-constraint). To add the title and a short description the properties `schema:name` and `schema:description` are used respectively.

### unit (number, percent, meter, gram, milliter per day ...)
To describe the unit of the values in a dimension the respecitive `qudt:Unit` shall be attached to the [Cube Constraint per Dimension](https://github.com/zazuko/rdf-cube-schema#metadata-and-validation-constraint) with `qudt:unit`.

### scaleType (nominal, ordinal, interval, ratio)
To provide more information on the statistical property of the scale of measure is described by `qudt:NominalScale`, `qudt:OrdinalScale`, `qudt:IntervalScale` or `qudt:RatioScale` which is attached through `qudt:scaleType` to the [Cube Constraint per Dimension](https://github.com/zazuko/rdf-cube-schema#metadata-and-validation-constraint).

The different scaleTypes hint about features which can be used for visualization properties:

* `qudt:NominalScale`: Expects the dimension to be either Resource (connected by an URI) or a value with any kind of dataType.
* `qudt:OrdinalScale`: Expects the dimesion to be either:
	* A Resource (connected by an URI): In this case the Resource should provide `schema:position` on the elements which provides a lexical ordering (best to use integer numbers). Further can be expected that the order in `sh:in` of the [shape constraint](https://github.com/zazuko/rdf-cube-schema#shapes) is correctly ordered.
	* Or value where the lexical order has a meaning. (e.g. `1th`, `2nd`, `3rd`).
* `qudt:IntervalScale`: Expects the dimension to be values with a numeric dataType and the unit not to contradict the correct Scale.
* `qudt:RatioScale`: Expects the dimension to be values with a numeric dataType and the unit not to contradict the correct Scale.

### dataType (string, boolean, int, float, ...)

In addition to honor a selected dataType on each literal value, the expected dataType per dimension is further added to the [Cube Constraint per Dimension](https://github.com/zazuko/rdf-cube-schema#metadata-and-validation-constraint) per `shacl:datatype`.

### dataKind (temporal / spatial)
Finally to express that the dimension provides a specific _kind_ of data which is necessary to select the correct visual representation we add `https://cube.link/meta/dataKind/` with the following structure possible values:

* [`schema:GeoCoordinates`](https://schema.org/GeoCoordinates): To hint that the dimension does provide Resources with latitutde and longitude which can be shown on a map.
  ```turtle
  @prefix: <https://cube.link/meta/dataKind/>
  
  <dimension> meta:dataKind [ a schema:GeoCoordinates ].
  ```
* [`schema:GeoShape`](https://schema.org/GeoShape): To hint that the dimension does provide Resources which have a shape which can be shown on a map.
* [`time:GeneralDateTimeDescription`](https://www.w3.org/TR/owl-time/#time:GeneralDateTimeDescription): To hint that the dimension does provide Resources which can be shown on a timeline.
  
  It is further possible to add [`time:unitType`](https://www.w3.org/TR/owl-time/#time:unitType) to hint about the precision in which the dimension should be presented. A [`time:TemporalUnit`](https://www.w3.org/TR/owl-time/#time:TemporalUnit) is expected: `time:unitYear`, `time:unitMonth`, `time:unitWeek`, `time:unitDay`, `time:unitHour`, `time:unitMinute` and `time:unitSecond`.
  
  ```turtle
  @prefix: <https://cube.link/meta/dataKind/>
  
  <dimension> meta:dataKind [ 
     a time:GeneralDateTimeDescription;
     time:unitType time:unitYear
  ].
  ```

## Version History of Cubes

To be able to have a continious history of a published cube there is a meta construct which can be put around a cube, describing a line of history of a cubes based on a `schema:CreativeWork`.

```
<https://example.org/cube-version-history> a schema:CreativeWork ;
   schema:hasPart <https://example.org/cube-version-history/1> ;
   schema:hasPart <https://example.org/cube-version-history/2> ;   
   schema:hasPart <https://example.org/cube-version-history/3> .
```

The version history has attached through `schema:hasPart` each time a fully described cube which can be interpreted independently. It is expected that the cubes in the same history line do not change the count of dimensions. All the other descriptions can change.

On the cube through `schema:CreativeWorkStatus` a status of the cube, like *Draft* or *Published* can be added. The status is expected to be a `schema:DefinedTerm`.

Finally, a cube can be invalidated or unlisted by adding `schema:expires` with the expiry date to the cube itself.

## Relations between quantitative values

(Originally raised as an issue in [rdf-cube-schema-viz](https://github.com/zazuko/rdf-cube-schema-viz/issues/15)).

Given an observation in  [RDF Cube Schema](https://github.com/zazuko/rdf-cube-schema) that defines multiple quantitative values (dimensions). It should be possible to express that there is a relation between two quantitative values..

### Problem & Approach

Given:

```turtle
<observation1> a Observation
<observation1> <value> 123.45
<observation1> <precision> 0.017
```

We want to express that an observation has a `<value>` and `<precision>` is the precision of `<value>`.

A standard reification/annotation approach would look like this in RDF

```turtle
# reification
<statement>
  <subject> <observation1>
  <predicate> <value>
  <object> 123.45

<statement> <precision> 0.017
```

On large datasets this would have a significant impact on query performance as it would require joins to get the `<precision>` of a particular `<value>` . In other words, it is not suitable for Cubes with many observations. It also makes the model more complicated to understand. 

A simplified approach would be to model quantitative values as entities, for example:

```
# simplified reification
<observation1> <value> [
    <value> 123.45;
    <precision> 0.017;
]
```

This is easier to understand due to forward-linking but it puts the value itself on an additional entity and thus requires a join per observation to fetch the value and its precision. 

The "new" approach would be to use RDF*:

```turtle
# RDF*
<observation1> <value> "123.45" 
<<<observation1> <value> "123.45">> <precision> 0.017
```

This is nice to read and write but it is too early to require that as support for it is relatively new. We also assume it does have performance impacts on triplestores if we would query that.

### Solution

Our approach moves the reification/annotation to the [constraint](https://github.com/zazuko/rdf-cube-schema#metadata-and-validation-constraint) of the cube, in particular to its dimension. There is one `sh:property` definition per dimension so the lookup only needs to be done once and is valid for all observations of that particular cube. 

```turtle
[ 
  sh:path <dimension/precision>
  # ... additional definitions for that sh:property
  cube:relation [ a cube:Relation ;
     # for the moment we recommend to define properties in your own namespace,
     # thus the "ex" namespace.
     # We might try to get that into another vocab like QUDT in the future or
     # provide generic properties on our own
     ex:precisionOf <dimension/value>
  ]
]
```

We define a `<relation>` for the cube dimension `<precision>`. The `<relation>` is of type `<PropertyRelation>`. It's `<target>` is the property `<value>`.

This approach is very generic and allows to express other relations as well, for example aggregations. Given the following triples:

```turtle
<observation1> a Cube
<observation1> <population> 10
<observation1> <populationMale> 7
<observation1> <populationFemale> 3
```

We want to express that `<population>` is the sum of` <populationMale>` and `<populationFemale>`. 

```turtle
[
  sh:path <populationMale>
  <relation> [ <AddRelation>
    <target> <population>
  ]
], [
  sh:path <populationFemale>
  <relation> [ <AddRelation>
    <target> <population>
  ]
]
```

The same semantics could be expressed the other way around:

```turtle
[
  sh:path <population>
  <relation> [ <SumRelation>
    <source> <populationMale>, <populationFemale>
  ], [ <SumRelation>
    <source> <populationAge0050>, <population5090> # restrictions on instances of a particular dimension
  ]
]
```

This is obviously advanced usage of the cube and increases its complexity. But it gives the expressiveness needed to describe complex relationship between data in a machine processable way. 

#### RDF terms

There is no recommendation on what properties and classes can or should be used to express the examples above. We only define:

* to use `dcterms:relation` to point to the relation itself. [Its definition](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#http://purl.org/dc/terms/relation) is generic enoughand does [not impose any reasoning implications](https://prefix.zazuko.com/dcterms%3Arelation) `
* `<source>` and `<target>` are terms used in the [Web Annotation Vocabulary](https://www.w3.org/TR/annotation-vocab/), they might or might not fit your use-case. In any way it is *not* recommend to re-use IRIs from this vocabulary as they do have reasoning implications.
* More formal classes and properties for common relations between two dimensions might be defined at a later stage to encourage re-use and interoperability.

## Nested hierarchies

(Originally raised as an issue in [rdf-cube-schema-viz](https://github.com/zazuko/rdf-cube-schema-viz/issues/6)).

Given:

```turtle
BASE <http://ex.org/>
<observation1> a <Observation> ;
  <municipality> <mun-nidau> .

<mun-nidau> a <Municipality> ;
  <district> <dist-bielbienne> ;
  <canton> <canton-bern> .

<dist-bielbienne> a <District> ;
  <canton> <canton-bern> .

<canton-bern> a <Canton> .
```

It should be possible to express nested hierarchies in a machine processable way. Think of nested taxonomies, spatial nesting etc. The information can be used to provide smart/useful default options for filters on cubes.

Our example can be visualized:

![Example of a hierarchy](./img/example-hierarchy.svg)

There are two paths that would be possible: `<observation1> -> <mun-nidau> -> <canton-bern>` or `<observation1> -> <mun-nidau> -> <district-bielbienne> -> <canton-bern> `. There is no way to know if the district should be followed or not by purely interpreting the data structure.

We address this issue by adding information about the nesting to the constraint (SHACL shape) of the cube.  On the `sh:property` of `<municipality>` we attach a new property called `<nextInHierarchy>`:


```turtle
[
  sh:path <municipality>
    <nextInHierarchy> <shape-municipality-canton-hierarchy>
]
```

This property points to minimal SHACL shape:

```turtle
<shape-municipality-canton-hierarchy> a NodeShape 
  sh:path <canton>
```

It points to the outgoing link with `sh:path` and the nesting ends there, as there is no `<nextInHierarchy>` defined on that particular shape. In other words, there is only one additional layer in this example that points to a `<canton>` and the complete shape represents the path `<observation1> -> <mun-nidau> -> <canton-bern>`.

> NOTE: We define `<nextInHierarchy>` purposely instead of re-using a property from SHACL to relate shapes. This ensures we only validate data within our realm.

To represent the more complex path, the contraint/shape might look like this:

```turtle
[
  sh:path <municipality>
    <nextInHierarchy> <shape-municipality-district-hierarchy>
]
```

linking to:

```turtle
<shape-municipality-district-hierarchy> a NodeShape 
  sh:path <district>
  <nextInHierarchy> <shape-district-canton-hierarchy> 
```

The level does not end here, we link from the `<district>` to the `<canton>`:

```turtle
<shape-district-canton-hierarchy> a NodeShape 
  sh:path <canton>
```

There is no outgoing link at that shape, in other words the nesting ends here. This represents the path  `<observation1> -> <mun-nidau> -> <district-bielbienne> -> <canton-bern> `.

