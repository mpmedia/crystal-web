module.exports = (app) ->
  # GET /doc
  app.get '/doc', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }
