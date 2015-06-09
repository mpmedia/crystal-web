module.exports = (app) ->
  # GET /user
  app.get '/user', (req, res) ->
    res.render 'user', {
      title: 'Crystal User'
    }
