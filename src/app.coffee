# load modules
body          = require 'body-parser'
cookie        = require 'cookie-parser'
express       = require 'express'
path          = require 'path'
multer        = require 'multer'
session       = require 'express-session'
redis         = require 'redis'
sessionClient = redis.createClient(6379, process.env.CRYSTAL_REDIS_HOST)
redisStore    = require('connect-redis') session
multer        = require 'multer'
bluebird      = require 'bluebird'
models        = require './models'

# get db
db = require './db.coffee'

# create app
app = express()
port = 8080

# set app title
title = 'Crystal - Open Source Code Generator for Every Language and Platform'

# disable app settings
app.disable 'etag'

# setup views
app.set 'views', path.join(__dirname, 'views')

# setup jade
app.set 'view engine', 'jade'

# setup static dirs
app.use '/font', express.static("#{__dirname}/public/font")
app.use '/formulas', express.static("#{__dirname}/public/formulas")
app.use '/images', express.static("#{__dirname}/public/images")
app.use '/scripts', express.static("#{__dirname}/public/js")
app.use '/styles', express.static("#{__dirname}/public/css")

# setup middleware
app.use body.urlencoded { extended: true }
app.use body.json()
app.use cookie()
app.use multer {
  dest: './uploads/'
}
app.use session({
  cookie:
    domain: '.crystal.sh'
  store: new redisStore {
    client: sessionClient
    host: process.env.CRYSTAL_REDIS_HOST
    port: 6379
    saveUninitialized: true
    resave: false
  }
  secret: 'PhKbgxBJjBOlAylyzeaBilyXdV0GfoQi'
})
process.on 'uncaughtException', (err) ->
  switch err.code
    when 'EADDRINUSE'
      console.log "Port #{port} is already in use."
    else
      console.log err.message

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


# load routes
require('./routes/accounts-connect')(app)
require('./routes/accounts')(app)
require('./routes/collections-name')(app)
require('./routes/collections')(app)
require('./routes/doc')(app)
require('./routes/docs')(app)
require('./routes/download')(app)
require('./routes/home')(app)
require('./routes/login')(app)
require('./routes/logout')(app)
require('./routes/module')(app)
require('./routes/modules-name')(app)
require('./routes/modules')(app)
require('./routes/privacy')(app)
require('./routes/registry')(app)
require('./routes/repositories')(app)
require('./routes/signup')(app)
require('./routes/support')(app)
require('./routes/terms')(app)
require('./routes/user-email')(app)
require('./routes/user')(app)
if process.env.CRYSTAL_DOMAIN == 'crystal.sh'
  app.all '*', (req, res, next) ->
    if req.secure
      next()
    res.redirect "https://#{req.host}#{req.url}"
    
app.use (req, res, next) ->
  res.status 404
  res.render 'error', {
    error: 'Page Not Found'
  }

# serve app
console.log 'Serving...'
app.listen port
