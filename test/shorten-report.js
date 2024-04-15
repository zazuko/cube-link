#!/usr/bin/env node

import { createPlaygroundUrl } from '@zazuko/shacl-playground'
import { shorten } from '@zazuko/s'

;(async function () {
  process.stdout.write(await shorten(createPlaygroundUrl(process.argv[2], process.argv[3])))
})()
