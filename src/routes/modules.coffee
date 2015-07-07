bluebird   = require 'bluebird'
formulator = require 'formulator'
marked     = require 'marked'
request    = require 'request'

AddModule = require '../formulas/forms/AddModule'

# enable promises
bluebird.promisifyAll request

module.exports = (app, db) ->
  # GET /modules/:name
  app.get '/modules/:collection_name/:module_name', (req, res) ->
    # prepare headers
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    data = {}
    
    collection_name = req.params.collection_name
    module_name = req.params.module_name
    
    bluebird.try () ->
      db.models.Collection.findOne {
        attributes: ['id','name']
        where:
          name: collection_name
      }
    
    .then (collection_data) ->
      data.collection = collection_data.dataValues
      
      db.models.Module.findOne {
        include:
          attributes: ['id','path','uuid']
          model: db.models.Repository
          include:
            attributes: ['id','access_token']
            model: db.models.Account
        where:
          collectionId: data.collection.id
          name: module_name
      }
    
    .then (module_data) ->
      if !module_data
        throw new Error "Module does not exist: #{req.params.name}"
      
      data.module = module_data.dataValues
      data.repository = data.module.repository.dataValues
      data.account = data.repository.account.dataValues
      
      request.getAsync {
        headers: headers
        url: "https://api.github.com/repositories/#{data.repository.uuid}/releases?access_token=#{data.account.access_token}&per_page=100"
      }
    
    .then (releases_resp) ->
      data.releases = []
      for release in JSON.parse releases_resp[0].body
        data.releases.push {
          tag: release.tag_name
        }
      
      request.getAsync {
        headers: headers
        url: "https://api.github.com/repositories/#{data.repository.uuid}/readme?access_token=2c7b0d02564a880c3726434fce0e880a9d44bd5e&per_page=100"
      }
      
    .then (readme_resp) ->
      readme = JSON.parse(readme_resp[0].body).content
      readme = new Buffer readme, 'base64'
      readme = readme.toString()
      marked readme, (err, content) ->
        data.readme = content
        res.render 'module', {
          account: data.account
          avatar: req.session.avatar
          collection: data.collection
          module: data.module
          readme: data.readme
          releases: data.releases
          repository: data.repository
          scripts: [
            'scripts/page/module.js'
          ]
          styles: [
            'styles/page/module.css'
          ]
        }
  
  # POST /modules
  app.post '/modules', (req, res) ->
    # prepare headers
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    form = new formulator AddModule, req.body
    
    data = {}
    
    bluebird.try () ->
      if !form.isValid()
        throw new Error 'Validation failed'
      
      db.models.Account.findOne {
        where:
          id: form.data.account
          userId: req.session.userId
      }
      
    .then (account_data) ->
      if !account_data
        throw new Error "Account does not exist: #{form.data.account}"
      
      data.account = account_data.dataValues
      
      # get account repos
      request.getAsync {
        headers: headers
        url: "https://api.github.com/repositories/#{form.data.repository}?access_token=#{data.account.access_token}"
      }
      
    .then (results) ->
      db.models.Repository.create {
        accountId: data.account.id
        providerId: data.account.providerId
        path: JSON.parse(results[0].body).full_name
        uuid: form.data.repository
        userId: req.session.userId
      }
      
    .then (repository_data) ->
      data.repositoryId = repository_data.dataValues.id
      
      db.models.Module.findOne {
        where:
          collectionId: form.data.collection
          name: req.body.name
      }
      
    .then (module_data) ->
      if module_data
        throw new Error 'Duplicate name'
      
      db.models.Module.create {
        accountId: form.data.account
        collectionId: form.data.collection
        color: form.data.color
        description: form.data.description
        name: form.data.name
        repositoryId: data.repositoryId
        userId: req.session.userId
      }
      
    .then (module) ->
      res.status(200).send module.dataValues
    
    .catch (e) ->
      res.status(400).send { error: e }