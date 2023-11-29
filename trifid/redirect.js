// @ts-check
const { Readable } = require('stream')
const { fetchBuilder, MemoryCache } = require('node-fetch-cache')

/**
 * Perform some redirections.
 *
 * @returns {import('express').RequestHandler}
 */
function factory () {
  const cachedFetch = fetchBuilder.withCache(new MemoryCache({
    ttl: 60 * 60 * 1000, // 1 hour
  }))

  return async (req, res, next) => {
    const requestPath = req.path

    // ignore health request from the cluster
    if (requestPath === '/health') {
      return next()
    }

    if (requestPath.match(/^\/[^/]+$/)) {
      return res.redirect('/')
    }

    if (requestPath.match(/^\/meta\/[^/]+$/)) {
      return res.redirect('/meta/')
    }

    if (requestPath.match(/^\/relation\/[^/]+$/)) {
      return res.redirect('/relation/')
    }

    // Redirect to a version of a shape (for routes: `/vX.Y.Z/shape/NAME` and `/latest/shape/NAME`)
    const shapePath = requestPath.split('/').slice(3).join('/')
    const versionMatch = requestPath.match(/^\/(?<version>v[0-9]+\.[0-9]+\.[0-9]+)\/shape\//)
    if (versionMatch || requestPath.startsWith('/latest/shape/')) {
      let versionPath = versionMatch?.groups?.version
      if (!versionPath) {
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
      }
      if (shapePath) {
        try {
          const rawGithub = await fetch(`https://raw.githubusercontent.com/zazuko/cube-link/${versionPath}/validation/${shapePath}.ttl`)
          if (rawGithub.ok) {
            res.set('Content-Type', 'text/turtle')
          } else {
            res.status(500)
          }
          // if the shape does not exist, we return a 404
          if (rawGithub.status === 404) {
            return res.sendStatus(404)
          }
          /** @type {any | null} */
          const body = rawGithub.body
          if (!rawGithub.body) {
            throw new Error('No body')
          }
          return Readable.fromWeb(body).pipe(res)
        } catch (e) {
          return res.status(502).send(`Error fetching shape: ${e.message}`)
        }
      }
    }

    next()
  }
}

module.exports = factory
