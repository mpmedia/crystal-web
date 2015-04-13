fs = require 'fs'

module.exports = (app, title) ->
  app.use '/gen', (req, res, next) ->
    generator = req.originalUrl.split('/')[2].split('.')[0]
    file = "lib/public/html/gen/#{generator}.html"
    if !fs.existsSync file
      res.status(404).send('404')
    res.sendfile file, { root: __dirname + '/..' }