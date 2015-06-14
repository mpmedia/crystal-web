# load modules
body          = require 'body-parser'
cookie        = require 'cookie-parser'
express       = require 'express'
path          = require 'path'
session       = require 'express-session'
redis         = require 'redis'
sessionClient = redis.createClient()
redisStore    = require('connect-redis') session

# create app
app = express()

# set app title
title = 'Crystal - Open Source Code Generator for Every Language and Platform'

# setup views
app.set 'views', path.join(__dirname, 'views')

# setup jade
app.set 'view engine', 'jade'

# setup static dirs
app.use '/font', express.static("#{__dirname}/public/font")
app.use '/images', express.static("#{__dirname}/public/images")
app.use '/scripts', express.static("#{__dirname}/public/js")
app.use '/styles', express.static("#{__dirname}/public/css")

# setup middleware
app.use body()
app.use cookie()
app.use session({
  store: new redisStore {
    client: sessionClient
    host: 'redis.crystal.sh'
    port: 6379
    saveUninitialized: true
    resave: false
  }
  secret: 'PhKbgxBJjBOlAylyzeaBilyXdV0GfoQi'
})

# load routes
require('./routes/home')(app)
require('./routes/collections')(app)
require('./routes/doc')(app)
require('./routes/docs')(app)
require('./routes/download')(app)
require('./routes/help')(app)
require('./routes/hub')(app)
require('./routes/login')(app)
require('./routes/modules')(app)
require('./routes/github2')(app)
require('./routes/logout')(app)
require('./routes/registry')(app)
require('./routes/search')(app)
require('./routes/user')(app)
app.use (req, res, next) ->
  res.status 404
  res.render '404', { url: req.url }

# serve app
console.log 'Serving...'
app.listen 8080
