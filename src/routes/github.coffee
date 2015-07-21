models = '../models'

module.exports = (app) ->
  
  # GET /login/github
  app.get '/login/github', (req, res) ->
    res.render 'github', {
      title: 'Crystal Login'
    }
