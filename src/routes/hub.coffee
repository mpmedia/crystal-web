module.exports = (app) ->
  # GET /hub
  app.get '/hub', (req, res) ->
    res.render 'hub', {
      avatar: if req.session.github then req.session.github.avatar_url else null
      title: 'Crystal Hub'
    }
