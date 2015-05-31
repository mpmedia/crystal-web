module.exports = (app, title) ->
  app.get '/login', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }