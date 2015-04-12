module.exports = (app, title) ->
  app.use '/doc', (req, res, next) ->
    file = "lib/public/html/doc.html"
    if !fs.existsSync file
      res.status(404).send('404')
    res.sendfile file, { root: __dirname + '/..' }