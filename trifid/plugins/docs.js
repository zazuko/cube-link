// @ts-check
import { readFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { Readable } from 'node:stream'
import { parsers } from '@rdfjs/formats-common'
import { sparqlSerializeQuadStream, sparqlSupportedTypes } from 'trifid-core'

const currentDir = dirname(fileURLToPath(import.meta.url))
const projectRoot = join(currentDir, '..', '..')

/**
 * The vocabulary documents served by this plugin.
 * `html` is the pre-rendered ReSpec documentation, `ttl` the source vocabulary.
 *
 * @type {Record<string, { html: string, ttl: string }>}
 */
const documents = {
  '/': { html: 'dist/cube.html', ttl: 'vocab.ttl' },
  '/meta/': { html: 'dist/meta.html', ttl: 'meta/meta.ttl' },
  '/relation/': { html: 'dist/relation.html', ttl: 'relation/relation.ttl' },
}

// RDF media types we can serve, in preference order.
const rdfTypes = [
  'text/turtle',
  'application/ld+json',
  'application/n-triples',
  'application/rdf+xml',
]

/**
 * Map the `?format=` query parameter to a media type.
 *
 * @type {Record<string, string>}
 */
const formatToMediaType = {
  ttl: 'text/turtle',
  jsonld: 'application/ld+json',
  nt: 'application/n-triples',
  xml: 'application/rdf+xml',
  html: 'text/html',
}

const cacheControl = 'public, max-age=120'

/**
 * @param {import('trifid-core').TrifidPluginArgument} trifid
 */
const factory = async (trifid) => {
  const { notFound } = trifid

  return {
    defaultConfiguration: async () => ({
      methods: ['GET'],
    }),
    routeHandler: async () => {
      /**
       * @param {import('fastify').FastifyRequest} request
       * @param {import('fastify').FastifyReply} reply
       */
      const handler = async (request, reply) => {
        const requestPath = request.url.split('?')[0]
        const document = documents[requestPath]
        if (!document) {
          await notFound(request, reply)
          return reply
        }

        // Decide which representation to serve: an explicit `?format=` wins,
        // otherwise we content-negotiate, defaulting to the HTML documentation.
        const requestedFormat = String(/** @type {any} */ (request.query)?.format ?? '')
        let mediaType = formatToMediaType[requestedFormat]
        if (!mediaType) {
          // `@fastify/accepts` (registered by trifid-core) decorates the request.
          const negotiated = /** @type {any} */ (request).accepts().type(['text/html', ...rdfTypes])
          mediaType = typeof negotiated === 'string' ? negotiated : 'text/html'
        }

        reply.header('Vary', 'Accept').header('Cache-Control', cacheControl)

        if (mediaType === 'text/html') {
          const html = await readFile(join(projectRoot, document.html), 'utf8')
          reply.type('text/html').send(html)
          return reply
        }

        const turtle = await readFile(join(projectRoot, document.ttl), 'utf8')
        const quadStream = parsers.import('text/turtle', Readable.from([turtle]))
        const serializeType = sparqlSupportedTypes.includes(mediaType) ? mediaType : 'text/turtle'
        const serialized = await sparqlSerializeQuadStream(quadStream, serializeType)
        reply.type(serializeType).send(serialized)
        return reply
      }
      return handler
    },
  }
}

export default factory
