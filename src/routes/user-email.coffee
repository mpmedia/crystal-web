bluebird = require 'bluebird'
crypto = require 'crypto'
formulator = require 'formulator'
EditUser = require '../formulas/forms/EditUser'
models = require '../models'

module.exports = (app) ->
  
  # GET /user/edit
  app.get '/user/edit', (req, res) ->
    models.User.findById(req.session.userId)
    .then (user) ->
      if !user
        res.status(400).send('Verification failed')
        return
      
      form = new formulator EditUser, user.dataValues
      
      res.render 'edit', {
        avatar: req.session.avatar
        form: form.toString()
        styles: [
          'styles/page/user.css'
        ]
        title: 'Crystal User'
      }
    .catch (e) ->
      res.render 'error', {
        error: e
        title: 'Error | Crystal'
      }
    
  
  # POST /user/edit
  app.post '/user/edit', (req, res) ->
    form = new formulator EditUser, req.body
    
    bluebird.try(() ->
      if !form.isValid()
        throw new Error 'Validation failed.'
    )
    .then () ->
      models.User.update(form.data, {
        where:
          id: req.session.userId
      })
      
    .then (user) ->
      if !user
        throw new Error 'Update failed.'
      
      res.redirect '/user/edit'
      
    .catch (e) ->
      res.render 'edit', {
        avatar: req.session.avatar
        error: e
        form: form.toString()
        styles: [
          'styles/page/user.css'
        ]
        title: 'Crystal User'
      }
    
