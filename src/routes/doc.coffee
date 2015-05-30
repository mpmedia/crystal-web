fs = require 'fs'

module.exports = (app, title) ->
  app.use '/doc', (req, res, next) ->
    file = "lib/public/html/doc.html"
    if !fs.existsSync file
      res.status(404).render 'error', {
        styles: [
          'styles/page/error.css'
        ]
        title: 'Page Not Found'
      }
    res.sendfile file, { root: __dirname }