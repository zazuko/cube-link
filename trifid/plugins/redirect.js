// @ts-check
import { Readable } from 'node:stream'
import NodeFetchCache, { MemoryCache } from 'node-fetch-cache'

/**
 * Trifid plugin performing the cube.link redirects.
 *
 * It is registered as a Fastify `onRequest` hook (rather than a route handler)
 * so that it can run on every request before the regular routes:
 *
 *  - single-segment term IRIs (e.g. `/Cube`, `/meta/Hierarchy`) are redirected
 *    to their ontology document (`/`, `/meta/`, `/relation/`);
 *  - versioned shape IRIs (`/vX.Y.Z/shape/NAME`, `/ref/COMMIT/shape/NAME`,
 *    `/latest/shape/NAME`) are served from the matching file on GitHub.
 *
 * @param {import('trifid-core').TrifidPluginArgument} trifid
 */
const factory = async (trifid) => {
  const { server, logger } = trifid

  const cachedFetch = NodeFetchCache.create({
    cache: new MemoryCache({
      ttl: 60 * 60 * 1000, // 1 hour
    }),
  })

  server.addHook('onRequest', async (request, reply) => {
    const requestPath = request.url.split('?')[0]

    // ignore health request from the cluster
    if (requestPath === '/health') {
      return
    }

    // term IRI -> ontology document
    if (requestPath.match(/^\/[^/]+$/)) {
      reply.redirect('/')
      return reply
    }

    if (requestPath.match(/^\/meta\/[^/]+$/)) {
      reply.redirect('/meta/')
      return reply
    }

    if (requestPath.match(/^\/relation\/[^/]+$/)) {
      reply.redirect('/relation/')
      return reply
    }

    // Redirect to a version of a shape (for routes: `/vX.Y.Z/shape/NAME`, `/ref/COMMIT_ID/shape/NAME` and `/latest/shape/NAME`)
    const versionMatch = requestPath.match(/^\/((?<version>v[0-9]+\.[0-9]+\.[0-9]+)|(ref\/(?<ref>.+))|latest)\/shape\/(?<shapePath>.+)/)
    if (versionMatch) {
      let versionPath

      const { version, ref, shapePath } = versionMatch?.groups || {}
      if (!version && !ref) {
        const tags = await cachedFetch('https://api.github.com/repos/zazuko/cube-link/tags').then(async (res) => {
          if (!res.ok) {
            await res.ejectFromCache()
          }
          return res.json()
        }).catch(() => {
          return []
        })

        // if an issue was identified, we redirect to the main branch as a fallback
        if (!tags || !Array.isArray(tags) || tags.length < 1) {
          versionPath = 'main'
        } else {
          versionPath = tags[0].name
        }
      } else if (ref) {
        versionPath = ref
      } else if (version) {
        versionPath = version
      }

      try {
        const rawGithub = await fetch(`https://raw.githubusercontent.com/zazuko/cube-link/${versionPath}/validation/${shapePath}.ttl`)
        // if the shape does not exist, we return a 404
        if (rawGithub.status === 404) {
          reply.status(404).send()
          return reply
        }
        if (rawGithub.ok) {
          reply.header('Content-Type', 'text/turtle')
        } else {
          reply.status(500)
        }
        const body = rawGithub.body
        if (!body) {
          throw new Error('No body')
        }
        // eslint-disable-next-line n/no-unsupported-features/node-builtins
        reply.send(Readable.fromWeb(/** @type {any} */(body)))
        return reply
      } catch (e) {
        const message = e instanceof Error ? e.message : String(e)
        reply.status(502).send(`Error fetching shape: ${message}`)
        return reply
      }
    }

    logger.debug(`no redirect for ${requestPath}`)
  })
}

export default factory
