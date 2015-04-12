body    = require 'body-parser'
cookie  = require 'cookie-parser'
express = require 'express'
fs      = require 'fs'
path    = require 'path'
session = require 'express-session'

app = express()

# redirect all www requests
app.all /.*/, (req, res, next) ->
  host = req.header 'host'
  if host == 'www.crystal.sh'
    res.redirect 301, "http://crystal.sh#{req.url}"
  else if host != 'crystal.sh'
    res.redirect 301, 'http://crystal.sh'
  else
    next()

app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade' 
app.use '/font', express.static("#{__dirname}/public/font")
app.use '/images', express.static("#{__dirname}/public/images")
app.use '/scripts', express.static("#{__dirname}/public/js")
app.use '/styles', express.static("#{__dirname}/public/css")
app.use '/doc', (req, res, next) ->
  file = "lib/public/html/doc.html"
  if !fs.existsSync file
    res.status(404).send('404')
  res.sendfile file, { root: __dirname + '/..' }
app.use '/gen', (req, res, next) ->
  generator = req.originalUrl.split('/')[2].split('.')[0]
  file = "lib/public/html/gen/#{generator}.html"
  if !fs.existsSync file
    res.status(404).send('404')
  res.sendfile file, { root: __dirname + '/..' }
app.use '/user', (req, res, next) ->
  user = req.originalUrl.split('/')[2].split('.')[0]
  file = "lib/public/html/user/#{generator}.html"
  if !fs.existsSync file
    res.status(404).send('404')
  res.sendfile file, { root: __dirname + '/..' }
app.use cookie()
app.use body()
app.use session({ secret: 'PhKbgxBJjBOlAylyzeaBilyXdV0GfoQi' })

generators = []

title = 'Crystal - Open Source Code Generator for Every Language and Platform'
app.get '/', (req, res) ->
  res.render 'index', { title: title }
app.get '/docs', (req, res) ->
  res.render 'docs', { title: title }
app.get '/generators', (req, res) ->
  res.render 'generators', {
    generators: generators,
    title: title
  }
app.get '/help', (req, res) ->
  res.render 'help', { title: title }
app.get '/login', (req, res) ->
  res.render 'login', { title: title }
app.get '/logout', (req, res) ->
  res.render 'logout', { title: title }
app.get '/install', (req, res) ->
  res.render 'install', { title: title }
app.get '/signup', (req, res) ->
  res.render 'signup', { title: title }
app.get '/tutorials', (req, res) ->
  res.render 'tutorials', { title: title }

console.log 'Serving...'
app.listen 80