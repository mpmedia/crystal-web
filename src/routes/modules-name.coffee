bluebird = require 'bluebird'
formulator = require 'formulator'
marked = require 'marked'
request = require 'request'
AddModule = require '../formulas/forms/AddModule'
# enable promises
bluebird.promisifyAll request

models = require '../models'

module.exports = (app) ->
  
  # get /modules/:collection/:module
  app.get '/modules/:collection/:module', (req, res) ->
    # prepare headers
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    data = {}
    
    collection_name = req.params.collection
    module_name = req.params.module
    
    bluebird.try () ->
      models.Collection.findOne {
        attributes: ['id','name']
        where:
          name: collection_name
      }
    
    .then (collection_data) ->
      data.collection = collection_data.dataValues
      
      models.Module.findOne {
        include:
          attributes: ['id','path','uuid']
          model: models.Repository
          include:
            attributes: ['id','accessToken']
            model: models.Account
        where:
          CollectionId: data.collection.id
          name: module_name
      }
    
    .then (module_data) ->
      if !module_data
        throw new Error "Module does not exist: #{req.params.name}"
      
      data.module = module_data.dataValues
      data.repository = data.module.Repository.dataValues
      data.account = data.repository.Account.dataValues
      
      request.getAsync {
        headers: headers
        url: "https://api.github.com/repositories/#{data.repository.uuid}/releases?access_token=#{data.account.accessToken}&per_page=100"
      }
    
    .then (releases_resp) ->
      data.releases = []
      for release in JSON.parse releases_resp[0].body
        data.releases.push {
          tag: release.tag_name
        }
      
      request.getAsync {
        headers: headers
        url: "https://api.github.com/repositories/#{data.repository.uuid}/readme?access_token=#{data.account.accessToken}&per_page=100"
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
          image_url: if req.host == 'crystal.sh' then 'https://s3.amazonaws.com/crystal-production/' else 'https://s3.amazonaws.com/crystal-alpha/'
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
        
    .catch (e) ->
      res.render 'error', {
        avatar: req.session.avatar
        error: e.toString()
      }
