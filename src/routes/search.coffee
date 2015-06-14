aws      = require 'aws-sdk'
bluebird = require 'bluebird'
uuid     = require 'node-uuid'

# scan modules table
db = new aws.DynamoDB({
  region: 'us-east-1'
  endpoint: 'http://localhost:8000'
})

# enable promises
bluebird.promisifyAll Object.getPrototypeOf(db)

module.exports = (app) ->
  # GET /search
  app.get '/search', (req, res) ->
    if !req.query.keywords and !req.session.keywords
      res.render 'search', {
        avatar: if req.session.github then req.session.github.avatar_url else null
        title: 'Search Crystal'
      }
      return
    
    if req.query.keywords
      req.session.keywords = req.query.keywords
    
    results = []
    db.scanAsync({
      TableName: 'Module'
      ExpressionAttributeNames:
        '#N': 'name'
      ExpressionAttributeValues:
        ':keywords':
          S: req.session.keywords
      FilterExpression: 'contains (#N, :keywords)'
      
    }).then((data) ->
      for item in data.Items
        results.push {
          id: item.id.S
          name: item.name.S
          type: 'Module'
          user: item.user.N
        }
        
      return db.scanAsync {
        TableName: 'Collection'
        ExpressionAttributeNames:
          '#N': 'name'
        ExpressionAttributeValues:
          ':keywords':
            S: req.session.keywords
        FilterExpression: 'contains (#N, :keywords)'
      }
      
    ).then((data) ->
      for item in data.Items
        results.push {
          id: item.id.S
          name: item.name.S
          type: 'Collection'
          user: item.user.N
        }
        
      res.render 'search', {
        avatar: if req.session.github then req.session.github.avatar_url else null
        keywords: req.session.keywords
        search:
          results: results
        styles: [
          'styles/page/search.css'
        ]
        title: 'Search Crystal'
      }
    )