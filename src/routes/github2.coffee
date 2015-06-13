aws     = require 'aws-sdk'
query   = require 'query-string'
request = require 'request'

module.exports = (app) ->
  app.get '/login/github', (req, res) ->
    handleError = (error) ->
      res.status(400).send error
      
    handleGitHubAuth = (error, response, body) ->
      if error || response.statusCode != 200
        handleError 'Unable to validate creds'
        return
      
      data = query.parse body
      
      if data.error
        handleError 'Unable to validate creds'
        return
      
      req.session.githubSession = data
      
      request.get {
        headers:
          'User-Agent': 'Crystal'
        url: "https://api.github.com/user?access_token=#{req.session.githubSession.access_token}"
      }, handleUser
    
    handleUser = (error, response, body) ->
      if error || response.statusCode != 200
        handleError 'Unable to validate creds'
        return
      
      body = JSON.parse body
      req.session.github = body
      
      # scan modules table
      db = new aws.DynamoDB({
        region: 'us-east-1'
        endpoint: 'http://localhost:8000'
      })
      db.getItem {
        AttributesToGet: [
          'repository'
        ]
        TableName: 'Module'
        Key: {
          "id": {
            "S": "official.express"
          }
        }
      }, (err, data) ->
        console.log err
        console.log data
        
        res.redirect '/'
    
    request.post {
      form:
        client_id: process.env.GITHUB_CLIENT_ID
        client_secret: process.env.GITHUB_CLIENT_SECRET
        code: req.query.code
        redirect_uri: process.env.GITHUB_REDIRECT_URI
      url: 'https://github.com/login/oauth/access_token'
    }, handleGitHubAuth