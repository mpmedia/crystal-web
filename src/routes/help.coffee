module.exports = (app) ->
  # GET /help
  app.get '/help', (req, res) ->
    res.render 'help', {
      avatar: req.session.avatar
      title: 'Crystal Help'
    }
