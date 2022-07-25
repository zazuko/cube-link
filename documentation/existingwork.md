# Related Work

## RDF Data Cube Vocabulary

The [[[vocab-data-cube]]] is probably the oldest vocabulary in the domain of RDF for representing cubes. The authors of this document used RDF Data Cubes extensively in the past and ran into multiple issues with it.

The authors of this specification are grateful for the work done by the original authors of the RDF Data Cube Vocabulary specification. This work would not have been possible without it and some parts look pretty much like the RDF Data Cube Vocabulary.

It was considered to either clarify or update the RDF Data Cube Vocabulary specification. For the sake of simplicity, it was decided to start from scratch.

### Issues with RDF Data Cube Vocabulary

* The metadata model is overly complex.
    * Many additional nodes are introduced that make querying the data in the real world overly complex.
    * Generating proper metadata from basic cubes is not easy, which increases complexity for automated pipelines.
* There is a mix of forward- and backward-linking within the metadata model.
* [Follow your nose](https://patterns.dataincubator.org/book/follow-your-nose.html) is often not possible.
* There is more than one way to do it. Different people interpret the spec differently, which makes it very hard to write libraries that consume generic RDF Data Cubes.
* There is a clear focus on [SDMX](https://en.wikipedia.org/wiki/SDMX), which introduces too rigorous restrictions and/or examples for use-cases outside the statistical domain.
* Re-use of dimensions is not very common in the RDF Data Cube vocabulary, which makes it much harder to compare data across data providers.

There are at least two efforts that extend the RDF Data Cube Vocabulary to address some of its limitations:

* [[[?qb4st]]]
* [QB4OLAP](https://github.com/lorenae/qb4olap/wiki)

Both efforts could likely be solved/addressed within the _Cube Schema_ approach, this needs to be validated by interested parties.

## SSN

The [[[vocab-ssn]]] defines a simplified model for describing observations from a sensor in RDF.

The [Observation](https://www.w3.org/TR/vocab-ssn/#SOSAObservation) model is at least inspired by the RDF Data Cube Vocabulary but it is not very useful for use-cases outside of sensor networks.

It should be relatively easy to replace SSN observations with the _Cube Schema_.