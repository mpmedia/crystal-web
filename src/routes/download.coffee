models = require '../models'

module.exports = (app) ->
  
  # GET /download
  app.get '/download', (req, res) ->
    res.render 'download', {
      avatar: req.session.avatar
      scripts: [
        'scripts/page/download.js'
      ]
      styles: [
        'styles/page/download.css'
      ]
      title: 'Download | Crystal'
    }
