#!/usr/bin/env node
import rdf from '@zazuko/env-node'
import formats from '@rdfjs-elements/formats-pretty'

rdf.formats.import(formats)

const prefixes = ['sh', 'rdf', 'schema', 'xsd', ['cube', 'https://cube.link/']]

;(async function () {
  const dataset = await rdf.dataset().import(rdf.formats.parsers.import('text/turtle', process.stdin))

  process.stdout.write(await dataset.serialize({ format: 'text/turtle', prefixes }))
})()
