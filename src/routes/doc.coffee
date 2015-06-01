route = (app, title) ->
  app.get '/doc', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }
    
module.exports = route