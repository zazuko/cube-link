# Cube Schema: Advanced Topics

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

To record a version the `schema:version` property can be used

A cube can be invalidated or unlisted by adding `schema:expires` with the expiry date to the cube itself.

## Annotation of status and scope of usage
As a guideline we propose the following predicates to annotate a cube with the status of a cube (Draft, Published, Hidden, ...) on the level ot the cube description.
   
A status of the cube, like *Draft* or *Published* can be added to the cube through `schema:CreativeWorkStatus`. The status is expected to be a `schema:DefinedTerm`.

Further to hint the usage of a cube for a specific application, and potentially to be filtered out for other applications, we propose the usage of `schema:workExample` attached to the cube. (The logic behind, is that if the cube is shown in an Application, it becomes an example how to interpret the cube – therefore it becomes a work example of that cube.)

Finally we propose `meta:applicationIgnores` attached to the Contraint of the dimension to hide this respective dimension for the specified Application.
(It shall use the same objects as used on `schema:workExample`.)

## Relations between quantitative values


Observation may hold dimensions that are related to each other as quantitative relation. Expressing this on the observation with blank nodes creates properly structured RDF, but creates performance and complexity issues when querying the Cube.


To overcome this limitation the relation can be expressed on the relevant [Dimension Constraints](#dimensionconstraints)
There is one `sh:property` definition per dimension so the lookup only needs to be done once and is valid for all observations of that particular cube.

<aside class='example' id='relexample' title='Expressing the relation'>

```turtle
PREFIX meta: <https://cube.link/meta/>
PREFIX relation: <https://cube.link/relation/>
   
[ 
  # the dimension description
  sh:path <dimension/standardError> ;
  # ... additional definitions for that sh:property
  meta:dimensionRelation [ 
    # We use a Class to indicate the e.g. the standard error.
    a relation:StandardError ;
    # A generic cube metadata property points to the relevant dimension.
    meta:relatesTo ex:measurement-dimension; # the other dimensions predicate defined by sh:path
  ]
]
```
</aside>
   
A relation between dimensions is described only with `cube` and `meta` vocabulary. The relation classes itself can be extended based on specific use cases. 
The controlled vocabulary introduced with namespace `PREFIX relation: <https://cube.link/relation/>` provides the most common relation Classes, and is proposed as a guideline.

This is an advanced usage of the cube and increases its complexity. But it gives the expressiveness needed to describe the complex relationship between data in a machine-processable way. 

## Hierarchies

<aside class='note'>
This part is still experimental and changes are to be expected. 
</aside>

Observations can be structured in hierarchies inside cubes. It is possible to define hierarchies which reside inside one dimension (e.g. categories, classifications) or also hierarchies which span over multiple dimensions. It is also possible to have hierarchies using external concepts.

To allow to reuse existing hierarchies described with e.g. (`schema:hasPart` / `schema:isPartOf`, [[[skos-primer]]] (https://www.w3.org/TR/skos-primer/) or similar ontologies) the following solution simply annotates one or multiple possible hierarchies. 

The hierarchies definition are always done *top-down* with one or multiple roots, following predicates of your choosing and the leaves must be the final observations inside one dimension.

The hierarchy annotation is attached to a cube dimension as a [meta:Hierarchy](meta#Hierarchy) through [meta:inHierarchy](meta#inHierarchy) (similar to a [meta:Relation](meta#Relation)).
It holds a name describing the hierarchy as such with `schema:name` and least one, but potentially multiple [meta:hierarchyRoot](meta#hierarchyRoot). Finally the connection between the root nodes and the first level below in the hierarchy is attached  through [meta:nextInHierarchy](meta#nextInHierarchy).


<aside class='example'>

```turtle
PREFIX meta: <https://cube.link/meta/>
PREFIX sh: <http://www.w3.org/ns/shacl#>

[
  meta:inHierarchy [
    a meta:Hierarchy ;
    meta:hierarchyRoot <https://ld.admin.ch/country/CHE> ;
    schema:name "CH - Canton" ;
    meta:nextInHierarchy [
      schema:name "Canton" ;
      sh:path <http://schema.org/containsPlace> ;
    ]
  ]
]
```
</aside>

The simplest example above puts the two concepts countries and cantons in relation.

### sh:path (connecting levels of a hierarchy)
With the use of [Property Paths](https://www.w3.org/TR/shacl/#property-paths) (`sh:path`) the connection between to levels in the hierarchy is expressed.

As a guideline we suggest support minimally support one step [Predicate Paths](https://www.w3.org/TR/shacl/#property-path-predicate) and [inverse](https://www.w3.org/TR/shacl/#property-path-inverse) one step Predicate Paths.

More complex paths will depend on the support of the used applications.

### sh:targetClass (differentiating concepts of a hierarchy level)
If the predicate using `sh:path` is not distinct enough, it is possible to add `sh:targetClass` specify additionally the Class of which the `sh:path` is pointing to.

<aside class='example'>

```turtle
PREFIX meta: <https://cube.link/meta/>
PREFIX sh: <http://www.w3.org/ns/shacl#>

meta:inHierarchy [
  a meta:Hierarchy ;
  meta:hierarchyRoot <https://ld.admin.ch/country/CHE> ;
  schema:name "CH - Canton" ;
  meta:nextInHierarchy [
    schema:name "Canton" ;
    sh:path  [ sh:inversePath <http://schema.org/containedInPlace> ] ;
    sh:targetClass <https://schema.ld.admin.ch/Canton> ;
  ]
]
```

</aside>

### Nested Levels

With the use of `meta:nextInHierarchy` it is possible to extend the number of levels indefinitely. Once a path does point to a instance of a concept which is attached by the defined dimension, the hierarchy for this element is complete. Therefore is it possible that the levels change for different levels.

<aside class='example'>

```turtle
PREFIX meta: <https://cube.link/meta/>
PREFIX sh: <http://www.w3.org/ns/shacl#>

  meta:inHierarchy [
    a meta:Hierarchy ;
    meta:hierarchyRoot <https://ld.admin.ch/country/CHE>;
    schema:name "CH - Canton - Municipality" ;
    meta:nextInHierarchy [
      schema:name "Canton" ;
      sh:path <http://schema.org/containsPlace> ;
      meta:nextInHierarchy [
        schema:name "Municipality" ;
        sh:path <http://schema.org/containsPlace> ;
      ]
    ]
  ]

```
</aside>




