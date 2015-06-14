aws      = require 'aws-sdk'
bluebird = require 'bluebird'
marked   = require 'marked'
request  = require 'request'
yaml     = require 'js-yaml'

# scan modules table
db = new aws.DynamoDB({
  region: 'us-east-1'
  endpoint: 'http://localhost:8000'
})

# enable promises
bluebird.promisifyAll Object.getPrototypeOf(db)
bluebird.promisifyAll request

module.exports = (app) ->
  # GET /registry
  app.get '/registry/:id', (req, res) ->
    dots = req.params.id.match(/\./g)
    
    # prepare headers for github
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    config = ''
    module = {}
    readme = {}
    repository = {}
    
    switch dots.length
      when 0
        db.queryAsync({
          TableName: 'Collection'
          IndexName: 'NameIndex'
          KeyConditions:
            name:
              AttributeValueList: [
                {
                  S: req.params.id
                }
              ]
              ComparisonOperator: 'EQ'
        })
      when 1
        db.queryAsync({
          TableName: 'Module'
          IndexName: 'NameIndex'
          KeyConditions:
            name:
              AttributeValueList: [
                {
                  S: req.params.id
                }
              ]
              ComparisonOperator: 'EQ'
              
        }).then((data) ->
          module = {
            name: data.Items[0].name.S
            repository: data.Items[0].repository.S
          }
          
          return db.queryAsync({
            TableName: 'Repository'
            KeyConditions:
              id:
                AttributeValueList: [
                  {
                    S: module.repository
                  }
                ]
                ComparisonOperator: 'EQ'
          })
          
        ).then((data) ->
          repository = {
            id: data.Items[0].id.S
            github_id: data.Items[0].github_id.N
            url: data.Items[0].url.S
          }
          
          return request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.github_id}/contents/.crystal/config.yml?access_token=#{req.session.githubSession.access_token}"
          }
        
        ).then((config_data) ->
          # validate config response
          config = JSON.parse config_data[0].body
          if config.error
            throw new Error "Failed to get config"
          config = new Buffer(config.content, 'base64').toString()
          
          return request.getAsync {
            headers: headers
            url: "https://api.github.com/repositories/#{repository.github_id}/readme?access_token=#{req.session.githubSession.access_token}"
          }
        
        ).then((readme) ->
          # validate readme response
          readme = JSON.parse readme[0].body
          if readme.error
            throw new Error "Failed to get readme"
          readme = new Buffer(readme.content, 'base64').toString()
          
          res.render 'registry', {
            avatar: if req.session.github then req.session.github.avatar_url else null
            config: config
            exports: yaml.safeLoad(config).exports
            name: module.name
            readme: marked(readme)
            repository: repository.url
            styles: [
              'styles/page/registry.css'
            ]
            title: 'Crystal Registry'
          }
        )
      when 2
        db.queryAsync({
          TableName: 'Export'
          IndexName: 'NameIndex'
          KeyConditions:
            name:
              AttributeValueList: [
                {
                  S: req.params.id
                }
              ]
              ComparisonOperator: 'EQ'
        })
      else
        throw new Error 'Invalid ID'