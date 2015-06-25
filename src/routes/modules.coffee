bluebird   = require 'bluebird'
formulator = require 'formulator'

AddModule = require '../formulas/forms/AddModule'

module.exports = (app, db) ->
  # POST /modules
  app.post '/modules', (req, res) ->
    form = new formulator AddModule, req.body
      
    bluebird.try () ->
      if !form.isValid()
        throw new Error 'Validation failed'
        
    .then () ->
      db.models.Module.findOne {
        where:
          name: req.body.name
      }
      
    .then (data) ->
      if data
        throw new Error 'Duplicate name'
      
      db.models.Module.create {
        accountId: form.data.account
        collectionId: form.data.collection
        color: form.data.color
        name: form.data.name
        userId: req.session.userId
      }
      
    .then (module) ->
      res.status(200).send module.dataValues
    
    .catch (e) ->
      console.log e
      res.status(400).send { error: e }