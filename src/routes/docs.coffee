module.exports = (app) ->
  # GET /docs
  app.get '/docs', (req, res) ->
    res.render 'docs', {
      title: 'Crystal Docs'
    }
