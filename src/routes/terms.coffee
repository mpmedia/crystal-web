module.exports = (app) ->
  # GET /terms
  app.get '/terms', (req, res) ->
    res.render 'terms', {
      avatar: req.session.avatar
      title: 'Crystal Terms of Use'
    }
