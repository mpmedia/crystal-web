module.exports = (app) ->
  # GET /hub
  app.get '/hub', (req, res) ->
    res.render 'hub', {
      title: 'Crystal Hub'
    }
