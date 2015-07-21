bluebird = require 'bluebird'
crypto = require 'crypto'
formulator = require 'formulator'
EditUser = require '../formulas/forms/EditUser'
models = require '../models'

module.exports = (app) ->
  getUser = (req, res, userId) ->
    data = {
      user:
        accounts: []
        collections: []
        repos: []
    }
    
    models.User.findOne {
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
      
      models.Account.findAll {
        attributes: ['login']
        include:
          model: models.Provider
          attributes: ['name']
        where:
          UserId: userId
      }
    
    .then (accounts_data) ->
      for account in accounts_data
        data.user.accounts.push account.dataValues
      
      models.Collection.findAll {
        where:
          UserId: userId
      }
    
    .then (collections_data) ->
      for collection in collections_data
        data.user.collections.push collection.dataValues
      
      models.Module.findAll {
        where:
          UserId: userId
      }
    
    .then (modules) ->
      models.Repository.findAll {
        where:
          UserId: userId
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
        image_url: if req.host == 'crystal.sh' then 'https://s3.amazonaws.com/crystal-production/' else 'https://s3.amazonaws.com/crystal-alpha/'
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
    
