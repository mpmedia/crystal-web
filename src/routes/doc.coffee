module.exports = (app, title) ->
  app.get '/doc', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }