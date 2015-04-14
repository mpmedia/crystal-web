fs = require 'fs'

module.exports = (app, title) ->
  app.use '/user', (req, res, next) ->
    user = req.originalUrl.split('/')[2].split('.')[0]
    file = "lib/public/html/user/#{user}.html"
    if !fs.existsSync file
      res.status(404).render 'error', {
        styles: [
          'styles/page/error.css'
        ]
        title: 'Page Not Found'
      }
    res.sendfile file, { root: __dirname + '/../..' }