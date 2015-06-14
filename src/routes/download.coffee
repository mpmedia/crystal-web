module.exports = (app) ->
  # GET /download
  app.get '/download', (req, res) ->
    res.render 'download', {
      avatar: if req.session.github then req.session.github.avatar_url else null
      title: 'Download Crystal'
    }
