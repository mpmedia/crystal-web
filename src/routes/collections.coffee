aws = require 'aws-sdk'
bluebird = require 'bluebird'
formulator = require 'formulator'
fs = require 'fs'
AddCollection = require '../formulas/forms/AddCollection'
EditCollection = require '../formulas/forms/EditCollection'
models = require '../models'

module.exports = (app) ->
  
  # DELETE /collections
  app.delete '/collections', (req, res) ->
    models.Collection.findOne {
      where:
        id: req.body.id
    }
    .then (collection) ->
      if !collection
        throw new Error 'Unknown Collection'
      else if collection.dataValues.UserId != req.session.userId
        throw new Error 'Not yours to delete'
      else if collection.dataValues.name != req.body.name
        throw new Error "Collection name does not match: #{collection.dataValues.name}"
        
      models.Collection.destroy {
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
    
    collections = models.Collection.findAll {
      attributes: ['id','name']
      order: 'name'
      where:
        UserId: req.session.userId
    }
    .then (collections_data) ->
      collections = []
      for collection in collections_data
        collections.push collection.dataValues
      
      res.status(200).send collections
    
    
  
  # PATCH /collections
  app.patch '/collections', (req, res) ->
    
    
    form = new formulator EditCollection, req.body
    if !form.isValid()
      res.status(400).send(form.errors)
      return
    
    # collect data
    data = {}
    
    models.Collection.findById(req.body.id)
    .then (collection) ->
      if !collection
        res.status(400).send { error: 'Unknown collection' }
        return
      else if collection.dataValues.UserId != req.session.userId
        res.status(400).send { error: 'Not yours to edit' }
        return
      
      collection.color = form.data.color
      if form.data.description and form.data.description.length
        collection.description = form.data.description
      collection.name = form.data.name
      
      return collection.save()
    
    .then (collection) ->
      data.collection = collection.dataValues
      
      if !req.files.image
        return
      
      aws.config.accessKeyId = process.env.AWS_S3_USER
      aws.config.secretAccessKey = process.env.AWS_S3_PASS
      
      s3 = new aws.S3 {
        params:
          Bucket: process.env.AWS_S3_BUCKET
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
    
  
  # POST /collections
  app.post '/collections', (req, res) ->
    
    
    
    data = {}
    
    form = new formulator AddCollection, req.body
    
    bluebird.try () ->
      if !form.isValid()
        for field of form.errors
          throw new Error field + ' ' + form.errors[field]
    
      models.Collection.findOne {
        where:
          name: req.body.name
      }
    
    .then (data) ->
      if data
        throw new Error 'Duplicate collection'
      
      collection = {
        color: form.data.color
        name: form.data.name
        website: form.data.website
        UserId: req.session.userId
      }
      if form.data.description and form.data.description.length
        collection.description = form.data.description
      
      models.Collection.create collection
    
    .then (collection) ->
      data.collection = collection.dataValues
      
      if !req.files.image
        return
      
      aws.config.accessKeyId = process.env.AWS_S3_USER
      aws.config.secretAccessKey = process.env.AWS_S3_PASS
      
      s3 = new aws.S3 {
        params:
          Bucket: process.env.AWS_S3_BUCKET
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
