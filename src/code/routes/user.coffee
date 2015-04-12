module.exports = (app, title) ->
  app.use '/user', (req, res, next) ->
    user = req.originalUrl.split('/')[2].split('.')[0]
    file = "lib/public/html/user/#{generator}.html"
    if !fs.existsSync file
      res.status(404).send('404')
    res.sendfile file, { root: __dirname + '/..' }