models = require '../models'

module.exports = (app) ->
  
  # GET /doc
  app.get '/doc', (req, res) ->
    res.render 'doc', {
      avatar: req.session.avatar
      title: 'Crystal Doc'
    }
