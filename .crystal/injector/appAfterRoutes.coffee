if process.env.CRYSTAL_DOMAIN == 'crystal.sh'
  app.all '*', (req, res, next) ->
    if req.secure
      next()
    res.redirect "https://#{req.host}#{req.url}"
    
app.use (req, res, next) ->
  res.status 404
  res.render 'error', {
    error: 'Page Not Found'
  }