module.exports = (app) ->
  # GET /help
  app.get '/help', (req, res) ->
    res.render 'help', {
      title: 'Crystal Help'
    }
