
app.locals.url = {
  api: "#{process.env.CRYSTAL_API_URL}/"
  hub: "#{process.env.CRYSTAL_HUB_URL}/"
  img: "#{process.env.CRYSTAL_IMG_URL}/"
  web: "#{process.env.CRYSTAL_WEB_URL}/"
}

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept'
  next()

if process.env.CRYSTAL_DOMAIN == 'crystal.sh'
  app.all '*', (req, res, next) ->
    if req.headers['x-forwarded-port'] == '443'
      next()
    else
      res.redirect "https://#{req.host}#{req.url}"