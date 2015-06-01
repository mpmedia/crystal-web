route = (app, title) ->
  app.get '/docs', (req, res) ->
    res.render 'docs', {
      title: 'Crystal Docs'
    }
    
module.exports = route