# Cube Schema: User eXperience Extension

To facilitate the visualization of Cubes or any other user experience related activity it is possible to extend the [Constraints](#constraints) to include additional metadata that describes the characteristics of the cube and its dimensions.
By providing this information in the Constraints tools used for displaying the data in the cube do not need to process and interpret the actual data in the cube to configure the visualization.

## Dimensions

To be able to understand the nature of a dimension we can type the dimension in the constraints. In general, we have at least two mandatory types per cube, the cube:MeasureDimension and the cube:KeyDimension.

### Classes

The following classes are used to define the various visualization element of the Cube Schema

#### cube:KeyDimension {#KeyDimension}

The KeyDimension tags one or multiple dimensions which are together uniquely identifying an observation. You can think of them as the Key in a relational database.

#### cube:MeasureDimension {#MeasureDimension}

 The MeasureDimension tags at least one dimension, but potentially multiple, which is the actual measurement, or statistical count attached to an observation.

<aside class='example' title='The use of  Dimension classes'>

```turtle
<temperature-sensor/cube/constraint> a sh:NodeShape, cube:Constraint ;
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

</aside>

### Properties

The following properties are used to define the various visualization element of the Cube Schema

#### schema:name 
A descriptive name of the Dimension, this description can be multilingual.
#### schema:description
A description of the Dimension, this description can be multilingual.

#### qudt:hasUnit
To describe the unit of the values in a dimension the respective `qudt:Unit` instance can be attached to a [Dimension Constraint](#dimensionconstraints) with the `qudt:hasUnit`   property.

#### qudt:scaleType

To provide more information on the statistical property scale of measure it can be described by `qudt:NominalScale`, `qudt:OrdinalScale`, `qudt:IntervalScale` or `qudt:RatioScale` which is attached through `qudt:scaleType` to the [Dimension Constraint](#dimensionconstraints). There can be only one `qudt:scaleType` per dimension.

The different scale types hint about features that can be used for visualization properties:

* `qudt:NominalScale`: Expects the dimension to be either Resource (connected by a URI) or a value with any kind of dataType.
* `qudt:OrdinalScale`: Expects the dimension to be either:
  * A Resource (connected by a URI): In this case, the Resource should provide `schema:position` on the elements which provides a lexical ordering (best to use integer numbers). Further can be expected that the order in `sh:in` of the [constraint](#dimensionconstraints) is correctly ordered.
  * Or value where the lexical order has a meaning. (e.g. `1th`, `2nd`, `3rd`).
* `qudt:IntervalScale`: Expects the dimension to be values with a numeric dataType and the unit not to contradict the correct Scale.
* `qudt:RatioScale`: Expects the dimension to be values with a numeric dataType and the unit not to contradict the correct Scale.

#### sh:datatype

To describe the datatype used by the dimension attach the `sh:datatype` to the [Dimension Constraint](#dimensionconstraints). 
Be aware that this implies the presence of a typed literal as the dimension value

#### meta:dataKind (temporal / spatial)
To express that the dimension provides a specific _kind_ of data which is necessary to select the correct visual representation you can add a `meta:dataKind` resource with the following possible structures:

* [`schema:GeoCoordinates`](https://schema.org/GeoCoordinates): To hint that the dimension does provide Resources with latitude and longitude which can be shown on a map.

<aside class='example'>

  ```turtle
  @prefix meta: <https://cube.link/meta/>
  
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

<section class="informative">

##### Complex representation of time

Representing temporal dimensions as literals typed as `xsd:date` or `xsd:dateTime` may be insufficient for complex scenarios. In such cases, data publishers may want to use the [Time Ontology in OWL](https://www.w3.org/TR/owl-time/) to represent temporal dimensions. This allows for the representation of complex temporal concepts, such as time periods, intervals, and repeating events, a well as joining cubes on the temporal dimension.

When using Time Ontology in a cube, the values of a temporal dimension are resources of type [`time:TemporalEntity`](https://prefix.zazuko.com/time:TemporalEntity) or one of its subtypes: [`time:Interval`](https://prefix.zazuko.com/time:Intetrval), [`time:Instant`](https://prefix.zazuko.com/time:Instant), or [`time:ProperInterval`.](https://prefix.zazuko.com/time:ProperInterval) The dimension should be expressed as a `time:GeneralDateTimeDescription` and have `Ordinal` scale type.

<aside class='example'>

```turtle
<observation> a cube:Observation ;
  time:hasTime <month/2000-06> .

<month/2000-06> a time:ProperInterval ;
  time:hasBeginning <instant/2000-06-01> ;
  time:hasEnd <instant/2000-06-30> ;
  schema:position "2000-06" .

<instant/2000-06-01> a time:Instant ;
  time:inXSDDateTimeStamp "2000-06-01T00:00:00+02:00"^^xsd:dateTime .

<instant/2000-06-30> a time:Instant ;
  time:inXSDDateTimeStamp "2000-06-30T23:59:59+02:00"^^xsd:dateTime .

<dimension/time> a sh:PropertyShape ;
  sh:path time:hasTime ;
  qudt:scaleType qudt:OrdinalScale ;
  meta:dataKind
   [
      a time:GeneralDateTimeDescription ;
      time:unitType time:unitMonth ;
   ] .      
```

</aside>

Please refer to the [Time Ontology in OWL](https://www.w3.org/TR/owl-time/) for more information on how to represent complex temporal concepts. You can also see [Lindas Core Entities](https://lindas.admin.ch/governance/core-entities/) for more examples.

</section>

#### sh:order
The sh:order can be used to indicate the relative order of the dimension, for use in visualizations. It should be used according to [the specification](https://www.w3.org/TR/shacl/#order) by using ascending order, for example, so that properties with smaller order are placed above (or to the left) of properties with a larger order. 
