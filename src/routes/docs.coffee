models = require '../models'

module.exports = (app) ->
  
  # GET /docs
  app.get '/docs', (req, res) ->
    res.render 'docs', {
      avatar: req.session.avatar
      title: 'Crystal Docs'
    }
