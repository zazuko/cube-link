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
