bluebird   = require 'bluebird'
crypto     = require 'crypto'
formulator = require 'formulator'

EditUser = require '../formulas/forms/EditUser'

module.exports = (app, db) ->
  # GET /user
  app.get '/user', (req, res) ->
    if !req.session.userId
      res.redirect '/'
    
    accounts = []
    collections = []
    user_id = ""
    user_company = ""
    user_email = ""
    user_location = ""
    user_name = ""
    user_url = ""
    user_username = ""
    user_website = ""
    
    db.models.User.findOne {
      where:
        id: req.session.userId
    }
    .then (user) ->
      if !user
        throw new Error "Please login"
      
      user_id = user.dataValues.id
      user_company = user.dataValues.company
      user_email = user.dataValues.email
      user_location = user.dataValues.location
      user_name = user.dataValues.name
      user_url = user.dataValues.url
      user_username = user.dataValues.username
      user_website = user.dataValues.website
      
      db.models.Account.findAll {
        attributes: ['login']
        include:
          model: db.models.Provider
          attributes: ['name']
        where:
          userId: req.session.userId
      }
    
    .then (accounts_data) ->
      accounts = []
      for account in accounts_data
        accounts.push account.dataValues
      
      db.models.Collection.findAll {
        where:
          userId: req.session.userId
      }
    
    .then (collections_data) ->
      collections = []
      for collection in collections_data
        collections.push collection.dataValues
      
      db.models.Module.findAll({
        where:
          userId: req.session.userId
      })
    
    .then (modules) ->
      db.models.Repository.findAll({
        where:
          userId: req.session.userId
      })
      
    .then (repository_data) ->
      repo_choices = []
      repos = []
      if repository_data.length
        for repo in repository_data
          repo_choices[repo.id.S] = repo.url.S
          repos.push {
            url: repo.url.S
          }
            
      avatar_hash = crypto
        .createHash('md5')
        .update(user_email)
        .digest 'hex'
      
      res.render 'user', {
        accounts: accounts
        avatar: req.session.avatar
        collections: collections
        company: user_company
        email: user_email
        location: user_location
        name: user_name
        repos: repos
        scripts: [
          'scripts/page/user.js'
        ]
        styles: [
          'styles/page/user.css'
        ]
        title: 'Crystal User'
        unverified: true
        username: user_username
        url: user_url
        website: user_website
      }
  
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