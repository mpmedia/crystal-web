aws = require 'aws-sdk'
bluebird = require 'bluebird'
formulator = require 'formulator'
fs = require 'fs'
models = require '../models'

module.exports = (app) ->
  
  # GET /collections/:name
  app.get '/collections/:name', (req, res) ->
    data = {}
    
    bluebird.try () ->
      models.Collection.findOne {
        include:
          attributes: ['id','username']
          model: models.User
        where:
          name: req.params.name
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
        image_url: if req.host == 'crystal.sh' then 'https://s3.amazonaws.com/crystal-production/' else 'https://s3.amazonaws.com/crystal-alpha/'
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
