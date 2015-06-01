# load modules
body    = require 'body-parser'
cookie  = require 'cookie-parser'
express = require 'express'
path    = require 'path'
session = require 'express-session'

# create app
app = express()
# set app title
title = 'Crystal - Open Source Code Generator for Every Language and Platform'
# setup views
app.set 'views', path.join(__dirname, 'views')
# setup static dirs
app.use font, express.static("public/font")
app.use images, express.static("public/images")
app.use scripts, express.static("public/js")
app.use styles, express.static("public/css")
# setup middleware
app.use body()
app.use cookie()
app.use session({ secret: 'PhKbgxBJjBOlAylyzeaBilyXdV0GfoQi' })

# load routes
require('./routes/home')(app)
require('./routes/doc')(app)
require('./routes/docs')(app)
require('./routes/help')(app)
require('./routes/hub')(app)
require('./routes/user')(app)

# serve app
console.log 'Serving...'
app.listen 8080