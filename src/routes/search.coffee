aws      = require 'aws-sdk'
bluebird = require 'bluebird'
uuid     = require 'node-uuid'

# scan modules table
db = new aws.DynamoDB({
  region: 'us-east-1'
  endpoint: 'http://localhost:8000'
})

# enable promises
bluebird.promisifyAll Object.getPrototypeOf(db)

module.exports = (app, db) ->
  # GET /search
  app.get '/search', (req, res) ->
    if !req.query.keywords and !req.session.keywords
      res.render 'search', {
        avatar: if req.session.github then req.session.github.avatar_url else null
        title: 'Search Crystal'
      }
      return
    
    if req.query.keywords
      req.session.keywords = req.query.keywords
    
    results = []
    db.models.Module.findAll({
      where:
        name: req.session.keywords
    }).then((modules) ->
      for mod in modules
        results.push {
          id: mod.dataValues.id
          name: mod.dataValues.name
          type: 'Module'
          user: mod.dataValues.userId
        }
        
      return db.models.Collection.findAll {
        where:
          name: req.session.keywords
      }
      
    ).then((collections) ->
      for collection in collections
        results.push {
          id: collection.dataValues.id
          name: collection.dataValues.name
          type: 'Collection'
          user: collection.dataValues.userId
        }
        
      res.render 'search', {
        avatar: req.session.avatar
        keywords: req.session.keywords
        search:
          results: results
        styles: [
          'styles/page/search.css'
        ]
        title: 'Search Crystal'
      }
    )