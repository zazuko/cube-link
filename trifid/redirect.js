const termRegex = /[^/]+$/;

function factory () {
  return (req, res, next) => {
    // ignore javascript files
    if (req.path.startsWith('/js/')) {
      return next();
    }

    // ignore health request from the cluster
    if (req.path === '/health') {
      return next();
    }

    // replace the last part of the path if it doesn't end with /
    if (termRegex.test(req.path)) {
      return res.redirect(req.path.replace(termRegex, ''));
    }

    next();
  }
}

module.exports = factory;
