models = require '../models'

module.exports = (app) ->
  
  # GET /support
  app.get '/support', (req, res) ->
    res.render 'support', {
      avatar: req.session.avatar
      title: 'Support | Crystal'
    }
