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

A status of the cube, like *Draft* or *Published* can be added to the cube through `schema:CreativeWorkStatus`. The status is expected to be a `schema:DefinedTerm`.

To record a version the `schema:version` property can be used

A cube can be invalidated or unlisted by adding `schema:expires` with the expiry date to the cube itself.



## Relations between quantitative values


Observation may hold dimensions that are related to each other as quantitative relation. Expressing this on the observation with blank nodes creates properly structured RDF, but creates performance and complexity issues when querying the Cube.


To overcome this limitation the relation can be expressed on the relevant [Dimension Constraints](#dimensionconstraints)
There is one `sh:property` definition per dimension so the lookup only needs to be done once and is valid for all observations of that particular cube.

<aside class='example' id='relexample' title='Expressing the relation'>

```turtle
PREFIX meta: <https://cube.link/meta/>
   
[ 
  sh:path <dimension/precision>
  # ... additional definitions for that sh:property
  meta:dimensionRelation [ 
    # We use a Class to indicate the e.g. the standard error.
    a relation:StandardError ;
    # A generic cube metadata property points to the relevant dimension.
    meta:relatesTo ex:dimension\/measurement;
  ]
]
```
</aside>
   
A relation between dimensions is described only with `cube` and `meta` vocabulary. The relation classes itself can be extended based on specific use cases. 
The controlled vocabulary introduced with namespace `PREFIX meta: <https://cube.link/meta/>` provides the most common relation Classes, and is proposed as a guideline.

This is an advanced usage of the cube and increases its complexity. But it gives the expressiveness needed to describe the complex relationship between data in a machine-processable way. 

### Classes

#### meta:Relation {#Relation}

A Cube:Relation resource is used to express the relation between different dimensions, the nature of the relationship is determined by the properties used. A Cube:Relation is linked to an observation through a [meta:relation](#relation) property. 
See [this example](#relexample).

### Properties

#### meta:relation {#relation}

This property is used on a Dimension Constraint to express a relation with other properties through a [meta:Relation](#Relation) instance, the nature of this relationship is determined by the properties used on the instance. 
See [this example](#relexample).

## Nested hierarchies

<p class="ednote" title="Do NOT implement">
  This chapter is undergoing a big rewrite, and should not be implemented
</p>

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

