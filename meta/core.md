# Meta vocabulary #

## Classes ##


### meta:Hierarchy {#Hierarchy}

A hierarchy is defined and can be named `schema:name`. This can help user interfaces to allow a selection in case of multiple hierarchies. 

### meta:Relation {#Relation}

A meta:Relation resource is used to express the relation or hierarchy between different dimensions, the nature of the relationship is determined by the properties used. A meta:Relation is linked to an observation through a [meta:relatesTo](#relatesTo) property. 

### meta:SharedDimension {#SharedDimension}

To be able to distinguish Dimensions that are defined inside a Cube from Dimensions that are used in multiple cubes, we have the type of meta:SharedDimension. Every dimension except the ones typed as a cube:MeasureDimension can also be a meta:SharedDimension.

<aside class='example' title='Shared Dimension'>

```turtle
[ a cube:KeyDimension, meta:SharedDimension ;
    schema:name "Canton"@en, "Kanton"@de, "Canton"@fr;
    sh:path example:canton ;
    qudt:scaleType qudt:NominalScale ;
  ].
```

</aside>

### meta:Limit {#Limit}

A type of [annotation](#annotation) which can be used to express a limit or target value for a dimension.

<aside class='example' title='Dimension with a target'>

```turtle
<cube/shape> sh:property [
  a cube:KeyDimension ;  
  sh:path ex:year ;
] , [
  a cube:MeasureDimension ;
  meta:annotation [
    a meta:Limit ;
    schema:maxValue 95 ;
    schema:name "Target 2020" ;
    meta:annotationContext [
      sh:path ex:year ;
      sh:hasValue <https://schema.ld.admin.ch/year/2020> ;
    ] ;
  ] ;
] .
```

</aside>

`schema:minValue` and `schema:maxValue` can be used together.

## Properties

### meta:dataKind (temporal / spatial) {#dataKind}
To express that the dimension provides a specific _kind_ of data which is necessary to select the correct visual representation you can add a `meta:dataKind` resource with the following possible structures:

* [`schema:GeoCoordinates`](https://schema.org/GeoCoordinates): To hint that the dimension does provide Resources with latitude and longitude which can be shown on a map.

<aside class='example'>

  ```turtle
  @prefix schema: <http://schema.org/> .
  @prefix meta: <https://cube.link/meta/> .
  
  <dimension> meta:dataKind [ a schema:GeoCoordinates ].
  ```

</aside>

* [`schema:GeoShape`](https://schema.org/GeoShape): To hint that the dimension does provide Resources that have a shape that can be shown on a map.
* [`time:GeneralDateTimeDescription`](https://www.w3.org/TR/owl-time/#time:GeneralDateTimeDescription): To hint that the dimension does provide Resources that can be shown on a timeline.
  
  It is further possible to add [`time:unitType`](https://www.w3.org/TR/owl-time/#time:unitType) to hint about the precision in which the dimension should be presented. A [`time:TemporalUnit`](https://www.w3.org/TR/owl-time/#time:TemporalUnit) is expected: `time:unitYear`, `time:unitMonth`, `time:unitWeek`, `time:unitDay`, `time:unitHour`, `time:unitMinute` and `time:unitSecond`.
  
<aside class='example'>

  ```turtle
  @prefix meta: <https://cube.link/meta/>
  
  <dimension> meta:dataKind [ 
     a time:GeneralDateTimeDescription;
     time:unitType time:unitYear
  ].
  ```

</aside>

### meta:dimensionRelation {#dimensionRelation}
A meta:dimensionRelation property is used to express the relation of this dimension in related to other dimension, examples are Deviation and StandardError


### meta:hierarchyRoot {#hierarchyRoot}

This property is mandatory and defines one or multiple root concepts. It is the starting point of the hierarchy which is then defined through a cascade of levels where the use of `sh:path` is connecting the concepts. The simplest case is only two levels, the root level and how they are connected to the observations in the dimension. If there are multiple levels they are nested with ['meta:nextInHierarchy'](#nextInHierarchy).

### meta:inHierarchy {#inHierarchy}

This property is used on a Dimension Constraint to express a hierarchy implemented. It points to a [meta:Hierarchy](#Hierarchy) which is the root level of the defined hierarchy. It is possible to add multiple different hierarchies on one dimension.

A hierarchy must have at least one `meta:hierarchyRoot`.

### meta:nextInHierarchy {#nextInHierarchy}

With `meta:nextInHierarchy` the next lower level is attached to the higher level or the root level of a hierarchy.

### meta:relatesTo {#relatesTo}

This property is used on a Dimension Constraint to express a relation with other properties through a [meta:Relation](#Relation) instance, the nature of this relationship is determined by the properties used on the instance. 
See [this example](../#relexample).

### meta:annotation {#annotation}

This property is used to add additional information to a dimension.

### meta:annotationContext {#annotationContext}

Links to dimension values to which the annotation applies.
The objects of `meta:annotationContext` MUST be well-formed [Property Shapes](https://www.w3.org/TR/shacl/#property-shapes).
The value of their `sh:path` MUST be an IRI of a cube's key dimension.
Only a subset of SHACL Constraints are supported which defined which observations that the annotation
applies to, namely:

1. `sh:hasValue` - to select specific observation value
2. `sh:in` - to select multiple observation values
2. `sh:minInclusive` - to select values greater or equal to a specific value
3. `sh:maxInclusive` - to select values smaller or equal to a specific value
4. `sh:minExclusive` - to select values greater than a specific value
5. `sh:maxExclusive` - to select values smaller than a specific value

In case of temporal dimensions, the constraint values are expected to be literals with datatypes `xsd:date`,
`xsd:dateTime` or `xsd:gYear`, or the IRIs of [temporal entities](https://lindas.admin.ch/governance/core-entities/).

<aside class='example' title='Dimension with a continuous limit on a temporal dimension'>

```turtle
<cube/shape> sh:property [
  a cube:KeyDimension ;  
  sh:path ex:year ;
] , [
  a cube:MeasureDimension ;
  meta:annotation [
    a meta:Limit ;
    schema:value 95 ;
    schema:name "Target 2020" ;
    meta:annotationContext [
      sh:path ex:year ;
      sh:minInclusive "2020-01-01"^^xsd:date ;
      sh:maxInclusive "2020-12-31"^^xsd:date ;
    ] ;
  ] ;
] .
```

</aside>
