route = (app, title) ->
  app.get '/hub', (req, res) ->
    res.render 'hub', {
      title: 'Crystal Hub'
    }
    
module.exports = route