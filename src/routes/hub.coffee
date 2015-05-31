module.exports = (app, title) ->
  app.get '/hub', (req, res) ->
    res.render 'hub', {
      title: 'Crystal hub'
    }