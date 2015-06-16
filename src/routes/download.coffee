module.exports = (app) ->
  # GET /download
  app.get '/download', (req, res) ->
    res.render 'download', {
      avatar: req.session.avatar
      title: 'Download Crystal'
    }
