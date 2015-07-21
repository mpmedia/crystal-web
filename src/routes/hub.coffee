models = require '../models'

module.exports = (app) ->
  
  # GET /hub
  app.get '/hub', (req, res) ->
    res.render 'hub', {
      avatar: req.session.avatar
      title: 'Crystal Hub'
    }
