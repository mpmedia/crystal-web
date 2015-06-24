bluebird   = require 'bluebird'
formulator = require '/Users/ctate/.crystal/dev/formulator'

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
        
      return db.models.Collection.destroy({
        where:
          id: req.body.id
          userId: req.session.userId
      })
    )
    .then((data) ->
      res.status(200).send { id: req.body.id }
    )
  
  # POST /collections
  app.post '/collections', (req, res) ->
    form = new formulator AddCollection, req.body
    if !form.isValid()
      res.status(400).send('Validation failed')
      return
    
    db.models.Collection.findOne({
      where:
        name: req.body.name
    })
    .then((data) ->
      if data
        res.status(400).send('Duplicate')
        return
      
      return db.models.Collection.create({
        color: form.data.color
        name: form.data.name
        userId: req.session.userId
      })
    )
    .then((collection) ->
      res.status(200).send collection.dataValues
    )
  
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