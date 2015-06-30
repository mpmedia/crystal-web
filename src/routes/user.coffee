bluebird   = require 'bluebird'
crypto     = require 'crypto'
formulator = require 'formulator'

EditUser = require '../formulas/forms/EditUser'

module.exports = (app, db) ->
  getUser = (req, res, userId) ->
    data = {
      user:
        accounts: []
        collections: []
        repos: []
    }
    
    db.models.User.findOne {
      where:
        id: userId
    }
    .then (user) ->
      if !user
        throw new Error "Please login"
      
      avatar_hash = crypto.createHash('md5').update(user.dataValues.email).digest 'hex'
      
      data.user.id = user.dataValues.id
      data.user.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
      data.user.company = user.dataValues.company
      data.user.email = user.dataValues.email
      data.user.location = user.dataValues.location
      data.user.name = user.dataValues.name
      data.user.url = user.dataValues.url
      data.user.username = user.dataValues.username
      data.user.website = user.dataValues.website
      
      db.models.Account.findAll {
        attributes: ['login']
        include:
          model: db.models.Provider
          attributes: ['name']
        where:
          userId: userId
      }
    
    .then (accounts_data) ->
      for account in accounts_data
        data.user.accounts.push account.dataValues
      
      db.models.Collection.findAll {
        where:
          userId: userId
      }
    
    .then (collections_data) ->
      for collection in collections_data
        data.user.collections.push collection.dataValues
      
      db.models.Module.findAll {
        where:
          userId: userId
      }
    
    .then (modules) ->
      db.models.Repository.findAll {
        where:
          userId: userId
      }
      
    .then (repository_data) ->
      data.repos = []
      if repository_data.length
        for repo in repository_data
          data.repos.push {
            url: repo.dataValues.uuid
          }
            
      avatar_hash = crypto
        .createHash('md5')
        .update(data.user.email)
        .digest 'hex'
      
      res.render 'user', {
        avatar: req.session.avatar
        scripts: [
          'scripts/page/user.js'
        ]
        styles: [
          'styles/page/user.css'
        ]
        title: 'Crystal User'
        unverified: true
        user: data.user
      }
    
    .catch (e) ->
      res.status(400).send { error: e.toString() }
      
  # GET /user
  app.get '/user', (req, res) ->
    if !req.session.userId
      res.redirect '/'
    
    getUser req, res, req.session.userId
  
  # GET /user/edit
  app.get '/user/edit', (req, res) ->
    db.models.User.findById(req.session.userId)
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
  
  # GET /users
  app.get '/users/:username', (req, res) ->
    if !req.session.userId
      res.redirect '/'
    
    db.models.User.findOne {
      where:
        username: req.params.username
    }
    
    .then (user_data) ->
      if !user_data
        throw new Error 'Unknown user'
      
      getUser req, res, user_data.dataValues.id
    
    .catch (e) ->
      res.status(400).send { error: e.toString() }
  
  # POST /user/edit
  app.post '/user/edit', (req, res) ->
    form = new formulator EditUser, req.body
    
    bluebird.try(() ->
      if !form.isValid()
        throw new Error 'Validation failed.'
    )
    .then () ->
      db.models.User.update(form.data, {
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
  
  # GET /user/verify
  app.get '/user/verify/:verification', (req, res) ->
    db.models.User.findOne {
      where:
        verification: req.params.verification
    }
    .then (user) ->
      if !user
        res.status(400).send('Verification failed')
        return
      
      user.verification = null
      user.verifiedAt = new Date
      user.save()
      
      res.redirect '/'