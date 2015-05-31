# load modules
body    = require 'body-parser'
cookie  = require 'cookie-parser'
express = require 'express'
fs      = require 'fs'
path    = require 'path'
session = require 'express-session'

# create app
app = express()

# set app title
title = 'Crystal - Open Source Code Generator for Every Language and Platform'

# setup jade
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

# setup static dirs
app.use '/font', express.static("#{__dirname}/public/font")
app.use '/images', express.static("#{__dirname}/public/images")
app.use '/scripts', express.static("#{__dirname}/public/js")
app.use '/styles', express.static("#{__dirname}/public/css")

# setup body, cookie, session
app.use body()
app.use cookie()
app.use session({ secret: 'PhKbgxBJjBOlAylyzeaBilyXdV0GfoQi' })

# load routes
require('./routes/home')(app, title)
require('./routes/doc')(app, title)
require('./routes/docs')(app, title)
require('./routes/help')(app, title)
require('./routes/user')(app, title)

# serve app
console.log 'Serving...'
app.listen 8080
