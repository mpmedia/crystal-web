route = (app, title) ->
  app.get '/user', (req, res) ->
    res.render 'user', {
      title: 'Crystal User'
    }
    
module.exports = route