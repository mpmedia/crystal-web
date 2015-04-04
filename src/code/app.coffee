body = require 'body-parser'
cookie = require 'cookie-parser'
express = require 'express'
fs = require 'fs'
jade = require 'jade'
path = require 'path'
request = require 'request'
session = require 'express-session'

app = express()
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade' 
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
app.use session({ secret: 'bigsecret' })

generators = []

app.get '/', (req, res) ->
  res.render 'index', { title: 'crystal code generator' }
app.get '/docs', (req, res) ->
  res.render 'docs', { title: 'crystal code generator' }
app.get '/generators', (req, res) ->
  res.render 'generators', {
    generators: generators,
    title: 'crystal code generator'
  }
app.get '/help', (req, res) ->
  res.render 'help', { title: 'crystal code generator' }
app.get '/login', (req, res) ->
  res.render 'login', { title: 'crystal code generator' }
app.get '/logout', (req, res) ->
  res.render 'logout', { title: 'crystal code generator' }
app.get '/install', (req, res) ->
  res.render 'install', { title: 'crystal code generator' }
app.get '/signup', (req, res) ->
  res.render 'signup', { title: 'crystal code generator' }

console.log 'Serving...'
app.listen 80