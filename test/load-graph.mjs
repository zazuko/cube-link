#!/usr/bin/env node

import env from '@zazuko/env-node'
import importGraphs from 'rdf-transform-graph-imports'
import open from 'barnard59-rdf/open.js'

(async () => {
  const quadStream = await open.call({ env }, process.argv[2])

  env.formats.serializers.import('text/turtle', quadStream.pipe(importGraphs(env))).pipe(process.stdout)
})()
