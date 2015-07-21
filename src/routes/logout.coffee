models = require '../models'

module.exports = (app) ->
  
  # GET /logout
  app.get '/logout', (req, res) ->
    req.session.destroy()
    res.redirect(if req.header('Referer') then req.header('Referer') else '/')
