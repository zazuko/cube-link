# RDF Cube Schema

## Best Practice

### Null/Empty values

In _RDF Cube Schema_, all dimensions are mandatory for a cube. If a value could not be measured, it should be expressed as such.

There is no generic "built-in" way to solve this in RDF. For some numeric datatypes, XML and [thus RDF](https://www.w3.org/TR/rdf11-concepts/#xsd-datatypes) defines ["not a number"](https://docstore.mik.ua/orelly/xml/schema/ch04_04.htm) (`NaN`) as a value. According to the specs, this is only valid for `xsd:float` and `xsd:double` and not for `xsd:decimal` and `xsd:integer`.

To provide a generic solution that works for all number and IRIs, _RDF Cube Schema_ provides `cube:Undefined`. The following example shows how to use it in `cube:Observation` and in the attached shape:

```turtle
# NamedNode Dimensions

<observation1> a cube:Observation;
  ex:namedNodeDimension cube:Undefined;

<observation2> a cube:Observation;
  ex:namedNodeDimension ex:realValue1;

<observation3> a cube:Observation;
  ex:namedNodeDimension ex:realValue2;
  
## Snippet for for the according shape:

[
    sh:path ex:namedNodeDimension;
    sh:nodeKind sh:IRI;
    sh:in(cube:Undefined, ex:realValue1, ex:realValue2)
]


# Literals Dimensions

<observation2> a cube:Observation;
  ex:literalDimension ""^^cube:Undefined.

## Snippet for for the according shape:

[
    sh:path ex:literalDimension;
    sh:nodeKind sh:Literal;
    sh:or([
        sh:datatype xsd:string
    ], [
        sh:datatype cube:Undefined
    ])
]
```

If it is necessary to state why the value is `cube:Undefined`, annotations should be used.
