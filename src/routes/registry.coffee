bluebird = require 'bluebird'
marked   = require 'marked'
request  = require 'request'
yaml     = require 'js-yaml'

# enable promises
bluebird.promisifyAll request

module.exports = (app, db) ->
  # GET /registry
  app.get '/registry/:id', (req, res) ->
    dots = req.params.id.match(/\./g)
    
    # prepare headers for github
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    config = ''
    license = ''
    module = {}
    readme = ''
    repository = {}
    
    switch dots.length
      when 0
        db.models.Collection.findOne({
          where:
            name: req.params.id
        })
      when 1
        db.models.Module.findOne({
          where:
            name: req.params.id
        }).then((data) ->
          module = {
            name: data.dataValues.name
            repository: data.dataValues.repositoryId
          }
          
          return db.models.Repository.findOne({
            where:
              id: module.repository
          })
          
        ).then((data) ->
          console.log data
          repository = {
            id: data.dataValues.id
            identifier: data.dataValues.identifier
            path: data.dataValues.path
            url: data.dataValues.url
          }
          
          return request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.identifier}/contents/.crystal/config.yml"
          }
        
        ).then((config_data) ->
          # validate config response
          config = JSON.parse config_data[0].body
          if config.error
            throw new Error "Failed to get config"
          config = new Buffer(config.content, 'base64').toString()
          
          return request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.identifier}/readme"
          }
        
        ).then((readme_data) ->
          # validate readme response
          readme = JSON.parse readme_data[0].body
          if readme.error
            throw new Error "Failed to get readme"
          readme = new Buffer(readme.content, 'base64').toString()
          
          return request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.identifier}/contents/LICENSE"
          }
        
        ).then((license_data) ->
          # validate license response
          license = JSON.parse license_data[0].body
          if license.error
            throw new Error "Failed to get license"
          license = new Buffer(license.content, 'base64').toString()
          
          res.render 'registry', {
            avatar: req.session.avatar
            config: config
            exports: yaml.safeLoad(config).exports
            license: license.replace /\n\n/g, '<br /><br />'
            name: module.name
            readme: marked(readme)
            repository: repository
            scripts: [
              'scripts/page/registry.js'
            ]
            styles: [
              'styles/page/registry.css'
            ]
            title: 'Crystal Registry'
          }
        )
      when 2
        db.models.Export.findOne({
          where:
            name: req.params.id
        })
      else
        throw new Error 'Invalid ID'