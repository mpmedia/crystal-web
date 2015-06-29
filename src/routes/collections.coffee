aws        = require 'aws-sdk'
bluebird   = require 'bluebird'
formulator = require 'formulator'
fs         = require 'fs'

AddCollection = require '../formulas/forms/AddCollection'
EditCollection = require '../formulas/forms/EditCollection'

module.exports = (app, db) ->
  # delete collection
  deleteCollection = (req, res) ->
    db.models.Collection.findOne({
      where:
        id: req.body.id
    })
    .then((collection) ->
      if !collection
        res.status(400).send('Unknown')
        return
      else if collection.dataValues.userId != req.session.userId
        res.status(400).send('Not yours to delete')
        return
        
      db.models.Collection.destroy({
        where:
          id: req.body.id
          userId: req.session.userId
      })
    )
    .then((data) ->
      res.status(200).send { id: req.body.id }
    )
  
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
    bluebird.try () ->
      collection = db.models.Collection.findOne({
        where:
          name: req.params.name
      })
    .then (collection) ->
      res.render 'collection', {
        avatar: req.session.avatar
        collection: collection.dataValues
        styles: [
          'styles/page/collection.css'
        ]
        title: "#{collection.dataValues.name} Collection | Crystal"
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
        return
      
      db.models.Collection.create {
        color: form.data.color
        name: form.data.name
        userId: req.session.userId
      }
    
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
      console.log e
      res.status(400).send(e)
  
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
      collection.name = form.data.name
      
      return collection.save()
    )
    .then((collection) ->
      res.status(200).send collection.dataValues
    )