module.exports = (app, title) ->
  # redirect all www requests
  #app.all /.*/, (req, res, next) ->
  #  host = req.header 'host'
  #  if host == 'www.crystal.sh'
  #    res.redirect 301, "http://crystal.sh#{req.url}"
  #  else if host != 'crystal.sh'
  #    res.redirect 301, 'http://crystal.sh'
  #  else
  #    next()
