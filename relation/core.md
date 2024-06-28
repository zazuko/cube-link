# Relation vocabulary #

## Classes ##

The classes in the relation vocabulary are instances of meta:DimensionRelation as well as a rdfs:Class.
This facilitates validation of the Dimension Constraints

### relation:StandardError  {#StandardError}
 
 The standard error is the standard deviation of the mean of the sample.

#### relation:StandardError1SD {#StandardError1SD}

 The standard error is the standard deviation of the mean of the sample.

#### relation:StandardError2SD {#StandardError2SD}
 The standard error is 2 standard deviation of the mean of the sample.

#### relation:StandardError3SD {#StandardError3SD}
The standard error is 3 standard deviation of the mean of the sample.

### relation:StandardDeviation {#StandardDeviation}
 
 Dispersion of the values of a random variable around its expected value.

### relation:Confidence {#MarginOfError}
 
Use `Confidence` to specify the level of uncertainty in the estimate. It can be used multiple times,
in which case add `dcterms:type` to each dimension relation to specify the type of confidence 
(Margin of Error, Confidence Interval, etc.).
 
#### relation:ConfidenceUpperBound and relation:ConfidenceUpperBound {#ConfidenceBounds}

In case of asymmetric confidence intervals, use `relation:ConfidenceUpperBound` together with 
`relation:ConfidenceUpperBound` to specify the upper and lower bounds of the confidence interval.

```turtle
[
  meta:dimensionRelation [ 
    a relation:ConfidenceLowerBound ;
    dcterms:type "Confidence interval" ;
    meta:relatesTo ex:lowerConfidence ; 
  ],
  meta:dimensionRelation [ 
    a relation:ConfidenceLowerBound ;
    dcterms:type "Confidence interval" ;
    meta:relatesTo ex:upperConfidence ; 
  ]
] .
```
