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
  # POST /modules
  app.post '/modules', (req, res) ->
    db.putItemAsync({
      TableName: 'Module'
      Item:
        id:
          S: uuid.v4()
        name:
          S: req.body.name
        repository:
          S: req.body.repository
        user:
          N: req.session.github.id.toString()
    }).then((data) ->
      console.log data
      res.redirect '/user'
    )