bluebird   = require 'bluebird'
formulator = require 'formulator'
marked     = require 'marked'
request    = require 'request'
yaml       = require 'js-yaml'

SearchRegistry = require '../formulas/forms/SearchRegistry'

# enable promises
bluebird.promisifyAll request

module.exports = (app, db) ->
  # GET /registry
  app.get '/registry', (req, res) ->
    form = new formulator SearchRegistry, { keywords: req.session.keywords }
    
    if !req.query.keywords and !req.session.keywords
      res.render 'search', {
        avatar: req.session.avatar
        form: form
        title: 'Search Crystal'
      }
      return
    
    if req.query.keywords
      req.session.keywords = req.query.keywords
    
    results = []
    db.models.Module.findAll({
      include: [
        {
          model: db.models.Collection
          attributes: ['id','name']
        }
        {
          model: db.models.User
          attributes: ['username']
        }
      ]
      where: ['module.name like ?', "%#{req.session.keywords}%"]
    }).then((modules) ->
      for mod in modules
        results.push {
          id: mod.dataValues.id
          collectionId: mod.dataValues.collection.id
          name: "#{mod.dataValues.collection.name}.#{mod.dataValues.name}"
          type: 'Module'
          user: mod.dataValues.user.username
        }
        
      db.models.Collection.findAll {
        include:
          model: db.models.User
          attributes: ['username']
        where: ['name like ?', "%#{req.session.keywords}%"]
      }
      
    ).then((collections) ->
      for collection in collections
        results.push {
          id: collection.dataValues.id
          name: collection.dataValues.name
          type: 'Collection'
          user: collection.dataValues.user.username
        }
        
      res.render 'search', {
        avatar: req.session.avatar
        form: form
        keywords: req.session.keywords
        search:
          results: results
        styles: [
          'styles/page/search.css'
        ]
        title: 'Search Crystal'
      }
    )
    
  # GET /registry/:id
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
          
          db.models.Repository.findOne({
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
          
          request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.identifier}/contents/.crystal/config.yml"
          }
        
        ).then((config_data) ->
          # validate config response
          config = JSON.parse config_data[0].body
          if config.error
            throw new Error "Failed to get config"
          config = new Buffer(config.content, 'base64').toString()
          
          request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.identifier}/readme"
          }
        
        ).then((readme_data) ->
          # validate readme response
          readme = JSON.parse readme_data[0].body
          if readme.error
            throw new Error "Failed to get readme"
          readme = new Buffer(readme.content, 'base64').toString()
          
          request.getAsync {
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