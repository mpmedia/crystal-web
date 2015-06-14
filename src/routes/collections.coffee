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
  # GET /collections
  app.get '/collections', (req, res) ->
    db.putItemAsync({
      TableName: 'Collection'
      Item:
        id:
          S: uuid.v4()
        name:
          S: req.params.name
        user:
          N: req.session.github.id.toString()
    }).then((data) ->
      console.log data
      res.redirect '/user'
    )
    
  # POST /collections
  app.post '/collections', (req, res) ->
    db.putItemAsync({
      TableName: 'Collection'
      Item:
        id:
          S: uuid.v4()
        name:
          S: req.body.name
        user:
          N: req.session.github.id.toString()
    }).then((data) ->
      console.log data
      res.redirect '/user'
    )