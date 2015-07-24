app.use (req, res, next) ->
  res.status 404
  res.render 'error', {
    error: 'Page Not Found'
  }