# Meta vocabulary #

## Classes ##

### meta:Relation {#Relation}

A meta:Relation resource is used to express the relation or hierarchy between different dimensions, the nature of the relationship is determined by the properties used. A meta:Relation is linked to an observation through a [meta:relation](#relation) property. 

### meta:DimensionRelation {#DimensionRelation}

A meta:DimensionRelation resource is used to express the relation of this dimension in related to other dimension, examples are Deviation and StandardError


## Properties

### meta:dataKind (temporal / spatial) {#dataKind}
To express that the dimension provides a specific _kind_ of data which is necessary to select the correct visual representation you can add a `meta:dataKind` resource with the following possible structures:

* [`schema:GeoCoordinates`](https://schema.org/GeoCoordinates): To hint that the dimension does provide Resources with latitude and longitude which can be shown on a map.

<aside class='example'>

  ```turtle
  @prefix: <https://cube.link/meta/>
  
  <dimension> meta:dataKind [ a schema:GeoCoordinates ].
  ```

</aside>

* [`schema:GeoShape`](https://schema.org/GeoShape): To hint that the dimension does provide Resources that have a shape that can be shown on a map.
* [`time:GeneralDateTimeDescription`](https://www.w3.org/TR/owl-time/#time:GeneralDateTimeDescription): To hint that the dimension does provide Resources that can be shown on a timeline.
  
  It is further possible to add [`time:unitType`](https://www.w3.org/TR/owl-time/#time:unitType) to hint about the precision in which the dimension should be presented. A [`time:TemporalUnit`](https://www.w3.org/TR/owl-time/#time:TemporalUnit) is expected: `time:unitYear`, `time:unitMonth`, `time:unitWeek`, `time:unitDay`, `time:unitHour`, `time:unitMinute` and `time:unitSecond`.
  
<aside class='example'>

  ```turtle
  @prefix: <https://cube.link/meta/>
  
  <dimension> meta:dataKind [ 
     a time:GeneralDateTimeDescription;
     time:unitType time:unitYear
  ].
  ```

</aside>

### meta:relation {#relation}

This property is used on a Dimension Constraint to express a relation with other properties through a [meta:Relation](#Relation) instance, the nature of this relationship is determined by the properties used on the instance. 
See [this example](#relexample).