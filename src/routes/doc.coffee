module.exports = (app) ->
  # GET /doc
  app.get '/doc', (req, res) ->
    res.render 'doc', {
      avatar: if req.session.github then req.session.github.avatar_url else null
      title: 'Crystal Doc'
    }
