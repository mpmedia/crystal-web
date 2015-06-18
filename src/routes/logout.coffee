module.exports = (app) ->
  # GET /logout
  app.get '/logout', (req, res) ->
    req.session.destroy()
    
    url = req.header('Referer') or '/'
    res.redirect url
