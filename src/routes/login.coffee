module.exports = (app) ->
  # GET /login
  app.get '/login', (req, res) ->
    console.log 'test'
    res.render 'login', {
      title: 'Crystal Login'
    }
