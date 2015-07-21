bluebird = require 'bluebird'
formulator = require 'formulator'
marked = require 'marked'
request = require 'request'
AddModule = require '../formulas/forms/AddModule'
# enable promises
bluebird.promisifyAll request

models = require '../models'

module.exports = (app) ->
  
  # post /modules
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
      
      models.Account.findOne {
        attributes: ['id', 'accessToken', 'ProviderId']
        where:
          id: form.data.account
          UserId: req.session.userId
      }
      
    .then (account_data) ->
      if !account_data
        throw new Error "Account does not exist: #{form.data.account}"
      
      data.account = account_data.dataValues
      
      # get account repos
      request.getAsync {
        headers: headers
        url: "https://api.github.com/repositories/#{form.data.repository}?access_token=#{data.account.accessToken}"
      }
      
    .then (results) ->
      models.Repository.create {
        path: JSON.parse(results[0].body).full_name
        uuid: form.data.repository
        AccountId: data.account.id
        ProviderId: data.account.ProviderId
        UserId: req.session.userId
      }
      
    .then (repository_data) ->
      data.repositoryId = repository_data.dataValues.id
      
      models.Module.findOne {
        where:
          name: req.body.name
          CollectionId: form.data.collection
      }
      
    .then (module_data) ->
      if module_data
        throw new Error 'Duplicate name'
      
      models.Module.create {
        color: form.data.color
        description: form.data.description
        name: form.data.name
        AccountId: form.data.account
        CollectionId: form.data.collection
        RepositoryId: data.RepositoryId
        UserId: req.session.userId
      }
      
    .then (module) ->
      res.status(200).send module.dataValues
    
    .catch (e) ->
      res.status(400).send { error: e }
