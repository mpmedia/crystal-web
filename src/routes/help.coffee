module.exports = (app) ->
  # GET /help
  app.get '/help', (req, res) ->
    res.render 'help', {
      avatar: if req.session.github then req.session.github.avatar_url else null
      title: 'Crystal Help'
    }
