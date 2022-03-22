function factory () {
  return (req, res, next) => {
    // ignore health request from the cluster
    if (req.path === '/health') {
      return next()
    }

    if (req.path.match(/^\/[^/]+$/)) {
      return res.redirect('/')
    }

    if (req.path.match(/^\/meta\/[^/]+$/)) {
      return res.redirect('/meta/')
    }

    if (req.path.match(/^\/relation\/[^/]+$/)) {
      return res.redirect('/relation/')
    }

    next()
  }
}

module.exports = factory
