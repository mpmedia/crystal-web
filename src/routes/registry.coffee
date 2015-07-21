bluebird = require 'bluebird'
formulator = require 'formulator'
marked = require 'marked'
request = require 'request'
yaml = require 'js-yaml'
SearchRegistry = require '../formulas/forms/SearchRegistry'
models = require '../models'

module.exports = (app) ->
  
  # GET /registry
  app.get '/registry', (req, res) ->
    # create form
    form = new formulator SearchRegistry, { keywords: req.query.keywords }
    
    find_module = {
      include: [
        {
          model: models.Collection
          attributes: ['id','color','name']
        }
        {
          model: models.User
          attributes: ['username']
        }
      ]
    }
    
    find_collection = {
      include:
        model: models.User
        attributes: ['username']
    }
    
    if req.query.keywords && req.query.keywords.length
      find_module.where = ['Module.name like ?', "%#{req.query.keywords}%"]
      find_collection.where = ['name like ?', "%#{req.query.keywords}%"]
    
    results = []
    models.Module.findAll find_module
    
    .then (modules) ->
      for mod in modules
        results.push {
          id: mod.dataValues.id
          color: mod.dataValues.Collection.color
          name: "#{mod.dataValues.Collection.name}/#{mod.dataValues.name}"
          type: 'Module'
          user: mod.dataValues.User.username
          CollectionId: mod.dataValues.Collection.id
        }
        
      models.Collection.findAll find_collection
      
    .then (collections) ->
      for collection in collections
        results.push {
          id: collection.dataValues.id
          color: collection.dataValues.color
          name: collection.dataValues.name
          type: 'Collection'
          user: collection.dataValues.User.username
        }
        
      res.render 'search', {
        avatar: req.session.avatar
        form: form
        image_url: if req.host == 'crystal.sh' then 'https://s3.amazonaws.com/crystal-production/' else 'https://s3.amazonaws.com/crystal-alpha/'
        keywords: req.query.keywords
        search:
          results: results
        styles: [
          'styles/page/search.css'
        ]
        title: 'Search Crystal'
      }
    
    .catch (e) ->
      res.render 'error', {
        error: e
        title: 'Error | Crystal'
      }
