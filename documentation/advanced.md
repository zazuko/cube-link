# RDF Cube Schema: Advanced Topics

The previous section described the properties of basic cubes, there are however situations where more complex observations or relations between observations need to be expressed. This section provides a set of best practices for various subjects.

## Version History of Cubes

To be able to have a continuous history of a published cube there is a meta construct that can be put around a cube, describing a line of the history of a cube based on a `schema:CreativeWork`.

<aside class='example'>

```turtle
<https://example.org/cube-version-history> a schema:CreativeWork ;
   schema:hasPart <https://example.org/cube-version-history/1> ;
   schema:hasPart <https://example.org/cube-version-history/2> ;   
   schema:hasPart <https://example.org/cube-version-history/3> .
```

</aside>

The version history has attached through `schema:hasPart` each time a fully described cube which can be interpreted independently. It is expected that the cubes in the same history line do not change the count of dimensions. All the other descriptions can change.

On the cube through `schema:CreativeWorkStatus` a status of the cube, like *Draft* or *Published* can be added. The status is expected to be a `schema:DefinedTerm`.

Finally, a cube can be invalidated or unlisted by adding `schema:expires` with the expiry date to the cube itself.


## Relations between quantitative values

Observation may hold dimensions that are related to each other, either as quantitative relation or aggregation relation. Expressing this on the observation with blank nodes creates properly structured RDF, but creates performance and complexity issues when querying the Cube.

To overcome this limitation the relation can be expressed on the relevant [Dimension Constraints](#dimensionconstraints)
There is one `sh:property` definition per dimension so the lookup only needs to be done once and is valid for all observations of that particular cube. 

<aside class='example' id='relexample' title='Expressing the relation'>

```turtle
[ 
  sh:path <dimension/precision>
  # ... additional definitions for that sh:property
  cube:relation [ a cube:Relation ;
     # we defined a property to indicate a precision on our own vocabulary
     # and point to the relevant dimension
     ex:precisionOf <dimension/value>
  ]
]
```
</aside>

We define a `<relation>` for the cube dimension `<precision>`. The `<relation>` is of type `<PropertyRelation>`. It's `<target>` is the property `<value>`.

This approach is very generic and allows to express other relations as well, for example, aggregations. Given the following triples:

<aside class='example'>

```turtle
<observation1> a Cube
<observation1> <population> 10
<observation1> <populationMale> 7
<observation1> <populationFemale> 3
```

</aside>

We want to express that `<population>` is the sum of` <populationMale>` and `<populationFemale>`. 

<aside class='example'>

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

</aside>

</aside>

The same semantics could be expressed the other way around:

<aside class='example'>

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

</aside>

This is an advanced usage of the cube and increases its complexity. But it gives the expressiveness needed to describe the complex relationship between data in a machine-processable way. 

### Classes

#### Cube:Relation {#Relation}

A Cube:Relation resource is used to express the relation between different dimensions, the nature of the relationship is determined by the properties used. a Cube:Relation is linked to an observation through a [cube:relation](#relation) property. 
See [this example](#relexample).

### Properties

#### cube:relation {#relation}

This property is used on a Dimension Constraint to express a relation with other properties through a [Cube:Relation](#Relation) instance, the nature of this relationship is determined by the properties used on the instance. 
See [this example](#relexample).

## Nested hierarchies

(Originally raised as an issue in [rdf-cube-schema-viz](https://github.com/zazuko/rdf-cube-schema-viz/issues/6)).

Given:

<aside class='example'>

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

</aside>

It should be possible to express nested hierarchies in a machine-processable way. Think of nested taxonomies, spatial nesting, etc. The information can be used to provide smart/useful default options for filters on cubes.

Our example can be visualized:

![Example of a hierarchy](./img/example-hierarchy.svg)

There are two paths that would be possible: `<observation1> -> <mun-nidau> -> <canton-bern>` or `<observation1> -> <mun-nidau> -> <district-bielbienne> -> <canton-bern> `. There is no way to know if the district should be followed or not by purely interpreting the data structure.

We address this issue by adding information about the nesting to the constraint (SHACL shape) of the cube.  On the `sh:property` of `<municipality>` we attach a new property called `<nextInHierarchy>`:

<aside class='example'>

```turtle
[
  sh:path <municipality>
    <nextInHierarchy> <shape-municipality-canton-hierarchy>
]
```

</aside>

This property points to minimal SHACL shape:

<aside class='example'>

```turtle
<shape-municipality-canton-hierarchy> a NodeShape 
  sh:path <canton>
```

</aside>

It points to the outgoing link with `sh:path` and the nesting ends there, as there is no `<nextInHierarchy>` defined on that particular shape. In other words, there is only one additional layer in this example that points to a `<canton>` and the complete shape represents the path `<observation1> -> <mun-nidau> -> <canton-bern>`.

> NOTE: We define `<nextInHierarchy>` purposely instead of re-using a property from SHACL to relate shapes. This ensures we only validate data within our realm.

To represent the more complex path, the constraint/shape might look like this:

<aside class='example'>

```turtle
[
  sh:path <municipality>
    <nextInHierarchy> <shape-municipality-district-hierarchy>
]
```

</aside>

linking to:

<aside class='example'>

```turtle
<shape-municipality-district-hierarchy> a NodeShape 
  sh:path <district>
  <nextInHierarchy> <shape-district-canton-hierarchy> 
```

</aside>

The level does not end here, we link from the `<district>` to the `<canton>`:

<aside class='example'>

```turtle
<shape-district-canton-hierarchy> a NodeShape 
  sh:path <canton>
```
</aside>

There is no outgoing link at that shape, in other words the nesting ends here. This represents the path  `<observation1> -> <mun-nidau> -> <district-bielbienne> -> <canton-bern> `.

