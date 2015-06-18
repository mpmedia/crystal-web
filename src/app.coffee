# load modules
body          = require 'body-parser'
cookie        = require 'cookie-parser'
express       = require 'express'
path          = require 'path'
session       = require 'express-session'
redis         = require 'redis'
sessionClient = redis.createClient()
redisStore    = require('connect-redis') session

# get db
db = require './db.coffee'

# create app
app = express()

# set app title
title = 'Crystal - Open Source Code Generator for Every Language and Platform'

# disable etag
app.disable 'etag'

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
require('./routes/home')(app, db)
require('./routes/collections')(app, db)
require('./routes/doc')(app, db)
require('./routes/docs')(app, db)
require('./routes/download')(app, db)
require('./routes/hub')(app, db)
require('./routes/login')(app, db)
require('./routes/modules')(app, db)
require('./routes/github2')(app, db)
require('./routes/logout')(app, db)
require('./routes/privacy')(app, db)
require('./routes/registry')(app, db)
require('./routes/signup')(app, db)
require('./routes/support')(app, db)
require('./routes/terms')(app, db)
require('./routes/user')(app, db)
app.use (req, res, next) ->
  res.status 404
  res.render '404', { url: req.url }

# serve app
console.log 'Serving...'
app.listen 8080
