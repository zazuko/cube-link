# Cube Schema: Core

This section describes the *Cube Schema* model.

The _Cube Schema_ defines a minimal set of classes and properties necessary to represent multi-dimensional arrays of data in [[[rdf11-concepts]]].

We describe the model, an elaborate example, and scripts to validate observations based on the constraint (SHACL shape) provided.

## Namespaces and Prefixes {#NS}

### Cube Schema
| PREFIX | IRI | Description |
| --- | --- | --- |
| `cube` | `https://cube.link/` | Cube Schema.|
| `meta` | `https://cube.link/meta/` | [Cube Schema meta data extension.](meta/)|
| `relation` | `https://cube.link/relation/` | [Cube Schema relation vocabulary.](relation/)|


### External
| PREFIX | IRI | Description |
| --- | --- | --- |
| schema | [http://schema.org/](http://schema.org) | To describe basic properties. |
| sh | [http://www.w3.org/ns/shacl#](https://www.w3.org/TR/shacl/) | Inherited from the Cube Schema for constratins. |
| qudt | [http://qudt.org/schema/qudt/](http://www.qudt.org/doc/DOC_SCHEMA-QUDT.html) | Describe scale of mesures. |
| unit | [http://qudt.org/vocab/unit/](http://www.qudt.org/doc/DOC_VOCAB-UNITS.html) | Describes units on values. |
| time | [http://www.w3.org/2006/time#](https://www.w3.org/TR/owl-time/) | A time description ontology. |
| geo | [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql) | OGC GeoSPARQL 1.0. |
| xsd | [http://www.w3.org/2001/XMLSchema#](http://www.w3.org/2001/XMLSchema) | XML Schema Datatypes. |
| skos | [http://www.w3.org/2004/02/skos/core#](http://www.w3.org/2004/02/skos/core) | SKOS Simple Knowledge Organization System. |

## Core Schema

The core schema is very simple and almost unconstrained from an RDF perspective. This ensures it can be used in many ways and does not restrict its usefulness due to too rigorous definitions.

![Basic Cube Schema structure](./img/cube-link-basic.svg)

### Classes

There are 4 classes defined in the Cube Schema

#### cube:Cube {#Cube}
Represents the entry point for a collection of one or more observation sets, conforming to some common dimensional structure.

#### cube:Constraint {#Constraint}
Specifies constraints that need to be met on the [Cube](#Cube). Used for metadata and validation. (Optional) For more information see [Cube Schema : Constraints](#constraints)

A [Constraint](#Constraint) for a cube. A Constraint is optional but recommended, it is used to:
* Define how data ([Observations](#Observation)) in a `Cube` can be validated.
* Add Cube-specific metadata (custom labels, translation to other languages, etc).

#### cube:Observation {#Observation}
A single observation in the cube may have one or more associated dimensions. A Observation can appear in one ore more [ObservationSets](#ObservationSet).

#### cube:ObservationSet {#ObservationSet}

An [ObservationSet](#ObservationSet) is a structure that acts as a container for multiple [Observations](#Observation). It can be used to group any set of [Observations](#Observation), as long as they use the same dimensions. There is on purpose no stronger semantics attached to this set, to make sure it can be used in almost any scenario. A cube can have one or more [ObservationSets](#ObservationSet) and an [Observation](#Observation) can appear in multiple [ObservationSets](#ObservationSet).

### Datatypes

#### cube:Undefined {#Undefined}

An observation which is not defined. for more information see [NULL and Empty values](#null-empty-values)

### Properties

The resources described by the various classes are connected by a small set of properties.

![Observations can be connected to an observer](./img/cube-link-observedBy.svg)

#### cube:observationSet {#observationSet}
Connects a cube with a set of observations.

#### cube:observationConstraint {#observationConstraint}
Connects a cube with a constraint for metadata and validation.

#### cube:observation {#observation}
Connects a set of observations with a single observation. 

#### cube:observedBy {#observedBy}
Connects an observation with the agent that created the observation. The agent can be a person, organization, device, or software. A description of the method to gather the data could be attached to the agent.


## Dimensions

> A dimension is a structure that categorizes facts and measures to enable users to answer business questions. Commonly used dimensions are people, products, place, and time ([Source: Wikidata](https://en.wikipedia.org/wiki/Dimension_(data_warehouse))).

In _Cube Schema_, facts, measures, and categories are all considered a dimension.

All [Observations](#Observation) need to provide the same set of dimensions, they cannot be optional. This ensures that cubes can be queried efficiently.

Unlike other RDF vocabularies in that domain, there is no specific class for a dimension. Creating a new _Cube Schema_ dimension would be the same as defining a new [RDF Property](https://www.w3.org/TR/rdf-schema/#ch_property). 

This encourages re-use and makes it much easier to cherrypick on existing RDF properties and use them as dimensions. Obvious examples are temporal properties like `schema:validFrom`, `dcterms:date`, `dcterms:temporal`, etc.

In general, any RDF Property can be considered for describing a dimension, except for heavily constrained properties that might lead to unwanted conclusions (inference) by [reasoners](http://www.w3.org/TR/sparql11-entailment/).

> Note that choosing a particular dimension will have implications. For querying cubes via SPARQL, spatial and temporal dimensions might only be filtered properly if the datatype used (i.e. `xsd:date`, `geo:asWKT`) is supported/optimized by the SPARQL endpoint. This is for example mostly _not_ the case for fragment datatypes like `xsd:gYear` etc.
>
> It has to be ensured that properties are not attached at the wrong level. Spatial dimensions for example are most likely *not* attached to the observation directly but to an instance of a dimension referenced in the observation. This is the case when the observation is referring to a static location where the observation is done, e.g. a sensor location. When however the actual location is the observation then it can be recorded as a dimension

Instances of a dimension can be [RDF literals](https://www.w3.org/TR/rdf11-primer/#section-literal) with [data types](https://www.w3.org/TR/rdf11-concepts/#section-Datatypes) (sometimes called _typed literals_) or IRIs. Only one literal must be attached to each dimension or must point to a single IRI.

Language tagged literals and all other (meta) data should be modeled as terms/concepts. For this purpose, [IRI's](https://www.w3.org/TR/rdf11-primer/#section-IRI) should be used and the literal(s) would be appended to that particular instance of a term/concept. This can be done e.g. by using [[[skos-primer]]] (https://www.w3.org/TR/skos-primer/) or schema.org [DefinedTerm](https://schema.org/DefinedTerm). As shown in the following example, a typical cube structure is a combination of dimensions with typed literals attached to the "observation" itself and dimensions that refer to concept groups via IRIs.

![An Observation often combines dimensions of typed literals with dimensions that point to IRIs](./img/cube-link-dimensions.svg)

In [[[turtle]]] syntax, the observation above looks like this:

<aside class='example' title='Simple observation'>

```turtle
<temperature-sensor/cube/observation/20190103T120000055Z> a cube:Observation ;
  cube:observedBy <temperature-sensor> ;
  dh:room <building1/level1/room1> ;
  dh:humidity 75.0 ;
  dh:lowBatteryPower false ;
  dh:temperature 0.0 ;
  dc:date "2019-01-03T12:00:00.055000+00:00"^^xsd:dateTime .
```

</aside>

`room1` is an IRI that has labels attached as language-tagged strings. 

<aside class='example'>

```turtle
<building1/level1/room1> a schema:Place ;
  schema:name "Room 1101"@en, "Raum 1101"@de, "Pièce 1101"@fr ;
  schema:inDefinedTermSet <rooms> ;
  schema:containedInPlace <building1/level1> .
```

</aside>

Nesting of relations can be expressed in a machine-readable form as well but is not part of the core Cube Schema.

### NULL and Empty values {#null-empty-values}

In _Cube Schema_, all dimensions are mandatory for a cube. If a value could not be measured, it should be expressed as such.

There is no generic "built-in" way to solve this in RDF. For some numeric datatypes, XML and [thus RDF](https://www.w3.org/TR/rdf11-concepts/#xsd-datatypes) defines ["not a number"](https://docstore.mik.ua/orelly/xml/schema/ch04_04.htm) (`NaN`) as a value. According to the specs, this is only valid for `xsd:float` and `xsd:double` and not for `xsd:decimal` and `xsd:integer`.

To provide a generic solution that works for all numbers and IRIs, _Cube Schema_ provides `cube:Undefined`. The following example shows how to use it in `cube:Observation` and in the attached shape:

<aside class='example' title='Name node Dimensions'>

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
```

</aside>

<aside class='example' title='Literals Dimensions'>

```turtle
<observation2> a cube:Observation;
  ex:literalDimension ""^^cube:Undefined.

## Snippet for the according shape:

[
    sh:path ex:literalDimension;
    sh:nodeKind sh:Literal;
    sh:or([
        sh:datatype xsd:string ; sh:minLength 1
    ], [
        sh:datatype cube:Undefined
    ])
]
```

</aside>

If it is necessary to state why the value is `cube:Undefined`, annotations should be used.

Additional constraints (like `sh:minLength` in the example) may be placed within the _real_ data type so that they do not apply to undefined values.


## Metadata

From a high-level point of view, the core classes and properties are enough to publish a valid cube, however, the absence of all metadata might make it hard for consumers to understand what the data is about.

### Cube Description
To add the title and a short description of the cube add the following properties directly on an instance of a [cube:Cube](#Cube)

#### schema:name 
A descriptive name of the Cube, this description can be multilingual.
#### schema:description
A description of the Cube, this description can be multilingual.

#### other properties
you are free to add other properties related to your Cube or the publication process of your Cube directly on the instance of the Cube.

<aside class='advisement'>

Although from the Open World concept point of view nothing forbids you to put metadata on every single observation, we do advise AGAINST that practice, in large cubes, this can dramatically increase the cube size and negatively impact the performance.

The [Constraints](#constraints) and [Visualization](#ux) section guide how to describe the structure of observations through the Constraints property.

</aside>
