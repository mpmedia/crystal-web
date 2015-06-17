module.exports = (app) ->
  # GET /privacy
  app.get '/privacy', (req, res) ->
    res.render 'privacy', {
      avatar: req.session.avatar
      title: 'Crystal Privacy Policy'
    }
