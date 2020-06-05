# RDF Cube Schema

## Best Practice

### Units

Units should be attached to the property used by the dimension with the `qudt:unit` predicate.

Some examples:

```turtle
sensor:brightness a rdf:Property;
  rdfs:label "Brightness";
  qudt:unit unit:Lux.

sensor:humidity a rdf:Property;
  rdfs:label "Humidity";
  qudt:unit unit:Percent.

sensor:pressure a rdf:Property;
  rdfs:label "Pressure";
  qudt:unit unit:Pascal.
  
sensor:powerIncoming a rdf:Property;
  rdfs:label "Power Incoming";
  qudt:unit unit:Watt .
```

### Null/Empty values

In _RDF Cube Schema_, all dimensions are mandatory for a cube. If a value could not be measured, it should be expressed as such.

For numeric datatypes, XML and [thus RDF](https://www.w3.org/TR/rdf11-concepts/#xsd-datatypes) defines ["not a number"](https://docstore.mik.ua/orelly/xml/schema/ch04_04.htm) (`NaN`) as a value. For `xsd:float` and `xsd:double` the following RDF is valid:

```
BASE <http://example.org/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

<observation> <measure> "NaN"^^xsd:double .
```

Please note that `NaN` is __not__ a valid value for `xsd:decimal`.

For [IRIs](https://www.w3.org/TR/rdf11-concepts/#section-IRIs), it could make sense to define a generic `Nil`-value. There is [rdf:nil](https://prefix.zazuko.com/rdf:nil) but its textual description limits its usage to an application in [RDF Lists](https://www.w3.org/TR/rdf-schema/#ch_list). 

If it is necessary to state why the value is`NaN`, annotations should be used.