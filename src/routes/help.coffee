route = (app, title) ->
  app.get '/help', (req, res) ->
    res.render 'help', {
      title: 'Crystal Help'
    }
    
module.exports = route