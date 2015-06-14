module.exports = (app) ->
  # GET /docs
  app.get '/docs', (req, res) ->
    res.render 'docs', {
      avatar: if req.session.github then req.session.github.avatar_url else null
      title: 'Crystal Docs'
    }
