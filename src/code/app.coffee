body = require 'body-parser'
cookie = require 'cookie-parser'
express = require 'express'
fs = require 'fs'
jade = require 'jade'
path = require 'path'
request = require 'request'
sass = require 'node-sass'
session = require 'express-session'

scss = sass.renderSync {
  file: "#{__dirname}/sass/main.scss"
  outputStyle: 'compressed'
}
fs.writeFileSync "#{__dirname}/public/css/main.css", scss.css

app = express()
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade' 
app.use '/scripts', express.static("#{__dirname}/public/js")
app.use '/styles', express.static("#{__dirname}/public/css")
app.use '/', express.static("#{__dirname}/public/html")
app.use cookie()
app.use body()
app.use session({ secret: 'bigsecret' })

generators = []

app.get '/', (req, res) ->
  res.render 'index', { title: 'crystal' }
app.get '/docs', (req, res) ->
  res.render 'docs', { title: 'crystal' }
app.get '/generators', (req, res) ->
  res.render 'generators', {
    generators: generators,
    title: 'crystal'
    }
app.get '/help', (req, res) ->
  res.render 'help', { title: 'crystal' }
app.get '/login', (req, res) ->
  res.render 'login', { title: 'crystal' }
app.get '/logout', (req, res) ->
  res.render 'logout', { title: 'crystal' }
app.get '/install', (req, res) ->
  res.render 'install', { title: 'crystal' }
app.get '/signup', (req, res) ->
  res.render 'signup', { title: 'crystal' }

request 'http://127.0.0.1:8080/generators', (error, response, body) ->
  if !error && response.statusCode == 200
    layout_path = "#{__dirname}/views/layout.jade"
    content_path = "#{__dirname}/views/gen.jade"
    layout = fs.readFileSync layout_path, 'utf8'
    content = fs.readFileSync content_path, 'utf8'
    
    generators = JSON.parse body
    for generator in generators
      html = jade.compile content, { filename: content_path }
      fs.writeFileSync "#{__dirname}/public/html/#{generator.name}.html", html({
        name: generator.name
        description: generator.description
        version: generator.versions[0]
      })
  
  console.log 'Serving...'
  app.listen 3000