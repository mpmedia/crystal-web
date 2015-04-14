fs = require 'fs'

module.exports = (app, title) ->
  app.use '/gen', (req, res, next) ->
    generator = req.originalUrl.split('/')[2].split('.')[0]
    file = "lib/public/html/gen/#{generator}.html"
    if !fs.existsSync file
      res.status(404).render 'error', {
        styles: [
          'styles/page/error.css'
        ]
        title: 'Page Not Found'
      }
    res.sendfile file, { root: __dirname + '/../..' }