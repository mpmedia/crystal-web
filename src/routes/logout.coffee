module.exports = (app) ->
  # GET /logout
  app.get '/logout', (req, res) ->
    res.redirect '/'
