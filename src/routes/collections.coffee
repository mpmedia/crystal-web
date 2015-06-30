aws        = require 'aws-sdk'
bluebird   = require 'bluebird'
formulator = require 'formulator'
fs         = require 'fs'

AddCollection = require '../formulas/forms/AddCollection'
EditCollection = require '../formulas/forms/EditCollection'

module.exports = (app, db) ->
  # delete collection
  deleteCollection = (req, res) ->
    db.models.Collection.findOne {
      where:
        id: req.body.id
    }
    .then (collection) ->
      if !collection
        throw new Error 'Unknown Collection'
      else if collection.dataValues.userId != req.session.userId
        throw new Error 'Not yours to delete'
      else if collection.dataValues.name != req.body.name
        throw new Error "Collection name does not match: #{collection.dataValues.name}"
        
      db.models.Collection.destroy {
        where:
          id: req.body.id
          userId: req.session.userId
      }
    
    .then (data) ->
      res.status(200).send { id: req.body.id }
    
    .catch (e) ->
      res.status(400).send { error: e.toString() }
  
  # GET /collections
  app.get '/collections', (req, res) ->
    collections = db.models.Collection.findAll {
      attributes: ['id','name']
      where:
        userId: req.session.userId
    }
    .then (collections_data) ->
      collections = []
      for collection in collections_data
        collections.push collection.dataValues
      
      res.status(200).send collections
  
  # GET /collections/:name
  app.get '/collections/:name', (req, res) ->
    data = {}
    
    bluebird.try () ->
      db.models.Collection.findOne {
        where:
          name: req.params.name
      }
      
    .then (collection_data) ->
      data.collection = collection_data.dataValues
      
      db.models.Module.findAll {
        include:
          attributes: ['id','path','uuid']
          model: db.models.Repository
        where:
          collectionId: data.collection.id
      }
    
    .then (modules_data) ->
      data.collection.modules = []
      for module in modules_data
        data.collection.modules.push {
          id: module.dataValues.id
          description: module.dataValues.description
          name: module.dataValues.name
          repository: module.dataValues.repository.path
        }
      
      db.models.FavoriteCollection.findOne {
        where:
          collectionId: data.collection.id
          userId: req.session.userId
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
      console.log e
      
      res.status 404
      res.render '404', {
        avatar: req.session.avatar
        styles: [
          'styles/page/404.css'
        ]
        url: req.url
      }
  
  # POST /collections
  app.post '/collections', (req, res) ->
    form = new formulator AddCollection, req.body
    if !form.isValid()
      throw new Error 'Validation failed'
    
    data = {}
    
    db.models.Collection.findOne {
      where:
        name: req.body.name
    }
    
    .then (data) ->
      if data
        throw new Error 'Duplicate collection'
      
      collection = {
        color: form.data.color
        name: form.data.name
        userId: req.session.userId
      }
      if form.data.description and form.data.description.length
        collection.description = form.data.description
      
      db.models.Collection.create collection
    
    .then (collection) ->
      data.collection = collection.dataValues
    
      aws.config.accessKeyId = process.env.AWS_S3_USER
      aws.config.secretAccessKey = process.env.AWS_S3_PASS
      
      s3 = new aws.S3 {
        params:
          Bucket: 'crystal-alpha'
          Key: 'collections/' + data.collection.id + '.svg'
      }
      
      bluebird.promisifyAll s3
      s3.uploadAsync {
        ACL: 'public-read'
        Body: fs.readFileSync "#{req.files.image.path}", 'utf8'
        ContentType: 'image/svg+xml'
      }
      
    .then (image) ->
      res.status(200).send data.collection
    
    .catch (e) ->
      res.status(400).send { error: e.toString() }
  
  # DELETE /collections
  app.delete '/collections', deleteCollection
  # POST /collections/delete
  app.post '/collections/delete', deleteCollection
  
  # POST /collections/edit
  app.post '/collections/edit', (req, res) ->
    form = new formulator EditCollection, req.body
    if !form.isValid()
      res.status(400).send('Validation failed')
      return
      
    db.models.Collection.findOne({
      where:
        id: req.body.id
    })
    .then((collection) ->
      if !collection
        res.status(400).send('Unknown')
        return
      else if collection.dataValues.userId != req.session.userId
        res.status(400).send('Not yours to edit')
        return
        
      return db.models.Collection.update({
        color: form.data.color
        name: form.data.name
      },{
        where:
          id: req.body.id
          userId: req.session.userId
      })
    )
    .then((data) ->
      res.redirect '/user'
    )
  
  # POST /collections/:name/favorite
  app.post '/collections/:name/favorite', (req, res) ->
    # collect data
    data = {}
    
    bluebird.try () ->
      # check if collection exists
      db.models.Collection.findOne {
        attributes: ['id']
        where:
          name: req.params.name
      }
      
    .then (collection) ->
      if !collection
        throw new Error 'Collection does not exist'
      
      data.collectionId = collection.dataValues.id
      
      # check if collection is favorite
      db.models.FavoriteCollection.findOne {
        where:
          collectionId: data.collectionId
          userId: req.session.userId
      }
      
    .then (favorite_collection) ->
      if !favorite_collection
        db.models.FavoriteCollection.create {
          collectionId: data.collectionId
          userId: req.session.userId
        }
      else if favorite_collection and req.body.favorite == 'false'
        db.models.FavoriteCollection.destroy {
          where:
            collectionId: data.collectionId
            userId: req.session.userId
        }
    
    .then () ->
      db.models.FavoriteCollection.findAll {
        attributes: ['id']
        where:
          collectionId: data.collectionId
      }
      
    .then (favorites_data) ->
      if !favorites_data
        data.favorites = 0
      else
        data.favorites = favorites_data.length
      
      db.models.Collection.update {
        favorites: data.favorites
      },{
        where:
          id: data.collectionId
      }
    
    .then () ->
      res.status(200).send { favorites: data.favorites }
      
    .catch (e) ->
      res.status(400).send { error: e.toString() }
  
  # PATCH /collections
  app.patch '/collections', (req, res) ->
    form = new formulator EditCollection, req.body
    if !form.isValid()
      res.status(400).send(form.errors)
      return
      
    db.models.Collection.findById(req.body.id)
    .then((collection) ->
      if !collection
        res.status(400).send { error: 'Unknown collection' }
        return
      else if collection.dataValues.userId != req.session.userId
        res.status(400).send { error: 'Not yours to edit' }
        return
      
      collection.color = form.data.color
      if form.data.description and form.data.description.length
        collection.description = form.data.description
      collection.name = form.data.name
      
      return collection.save()
    )
    .then((collection) ->
      res.status(200).send collection.dataValues
    )