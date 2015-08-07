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
port = 8081

# set app title
title = 'Crystal - Open Source Code Generator for Every Language and Platform'

# disable app settings
app.disable 'etag'

# setup views
app.set 'views', path.join(__dirname, 'views')

# setup jade
app.set 'view engine', 'jade'

# setup static dirs
app.use '/components', express.static("#{__dirname}/public/components")
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

if process.env.CRYSTAL_DOMAIN == 'crystal.sh'
  app.all '*', (req, res, next) ->
    if req.headers['x-forwarded-port'] == '443'
      next()
    else
      res.redirect "https://#{req.host}#{req.url}"

# load routes
require('./routes/hub')(app)
app.use (req, res, next) ->
  
  if req.host.match('hub\.crystal\.sh')
    # get collection/module name
    if req.url.match('\\.')
      url = req.url.split '\.'
      collection_name = url[0].substr 1
      module_name = url[1]
    else
      url = req.url.split '/'
      collection_name = url[1]
      module_name = url[2]
    
    # collect data
    data = {}
    
    if module_name and module_name.length
      bluebird.try () ->
        models.Collection.findOne {
          attributes: ['id','name']
          where:
            name: collection_name
        }

      .then (collection_data) ->
        if !collection_data
          throw new Error "Collection does not exist: #{collection_name}"
        
        data.collection = collection_data.dataValues
        
        models.Module.findOne {
          include:
            attributes: ['id','path','uuid']
            model: models.Repository
            include:
              attributes: ['id','accessToken']
              model: models.Account
          where:
            CollectionId: data.collection.id
            name: module_name
        }

      .then (module_data) ->
        if !module_data
          throw new Error "Module does not exist: #{module_name}"
        
        data.module = module_data.dataValues
        data.repository = data.module.Repository.dataValues
        data.account = data.repository.Account.dataValues
        
        res.render 'module', {
          account: data.account
          avatar: req.session.avatar
          collection: data.collection
          module: data.module
          repository: data.repository
          scripts: [
            'scripts/page/module.js'
          ]
          styles: [
            'styles/page/module.css'
          ]
        }
          
      .catch (e) ->
        res.render 'error', {
          avatar: req.session.avatar
          error: e.toString()
        }
      
    else
      bluebird.try () ->
        models.Collection.findOne {
          include:
            attributes: ['id','username']
            model: models.User
          where:
            name: collection_name
        }
        
      .then (collection_data) ->
        data.collection = collection_data.dataValues
        
        models.Module.findAll {
          include: [
            {
              attributes: ['id','path','uuid']
              model: models.Repository
            }
            {
              attributes: ['username']
              model: models.User
            }
          ]
          where:
            CollectionId: data.collection.id
        }
      
      .then (modules_data) ->
        data.collection.modules = []
        for module in modules_data
          data.collection.modules.push {
            id: module.dataValues.id
            description: module.dataValues.description
            name: module.dataValues.name
            repository: module.dataValues.Repository.path
            username: module.dataValues.User.dataValues.username
          }
        
        models.FavoriteCollection.findOne {
          where:
            CollectionId: data.collection.id
            UserId: req.session.userId
        }
        
      .then (favorite_data) ->
        if favorite_data
          data.collection.favorite = true
        
        res.render 'collection', {
          avatar: req.session.avatar
          collection: data.collection
          scripts: [
            'scripts/page/collections.js'
          ]
          styles: [
            'styles/page/collection.css'
          ]
          title: "#{data.collection.name} Collection | Crystal"
        }
        
      .catch (e) ->
        res.status 404
        res.render '404', {
          avatar: req.session.avatar
          styles: [
            'styles/page/404.css'
          ]
          url: req.url
        }
        
    return
  
  res.status 404
  res.render 'error', {
    error: 'Page Not Found'
  }

# serve app
console.log 'Serving...'
app.listen port
