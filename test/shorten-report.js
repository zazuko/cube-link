#!/usr/bin/env node

const SHACL_PLAYGROUND_URL = 'https://shacl-playground.zazuko.com/'
const SHORTENER = 'https://s.zazuko.com/api/v1/shorten/'

;(async function () {
  const params = new URLSearchParams({
    shapesGraph: process.argv[2],
    dataGraph: process.argv[3],
    dataGraphFormat: 'text/turtle',
    page: 2
  })

  const playgroundUrl = new URL(SHACL_PLAYGROUND_URL)
  playgroundUrl.hash = params.toString()

  const response = await fetch(SHORTENER, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      url: playgroundUrl.toString()
    })
  })
  process.stdout.write(await response.text())
})()
