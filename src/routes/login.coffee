module.exports = (app) ->
  # GET /login
  app.get '/login', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }
