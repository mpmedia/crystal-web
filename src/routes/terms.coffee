models = require '../models'

module.exports = (app) ->
  
  # GET /terms
  app.get '/terms', (req, res) ->
    res.render 'terms', {
      avatar: req.session.avatar
      title: 'Terms of Use | Crystal'
    }
