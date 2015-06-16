aws      = require 'aws-sdk'
bluebird = require 'bluebird'
query    = require 'query-string'
request  = require 'request'
uuid     = require 'node-uuid'

# scan modules table
db = new aws.DynamoDB({
  region: 'us-east-1'
  endpoint: 'http://localhost:8000'
})

# enable promises
bluebird.promisifyAll Object.getPrototypeOf(db)
bluebird.promisifyAll request

module.exports = (app) ->
  app.get '/login/github', (req, res) ->
    # validate github info
    if !process.env.GITHUB_CLIENT_ID or !process.env.GITHUB_CLIENT_SECRET or !process.env.GITHUB_REDIRECT_URI
      throw new Error "Internal server error"
    else if !req.query.code
      throw new Error "Code is required"
    
    # prepare headers for github
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    # login with github
    request.postAsync({
      form:
        client_id: process.env.GITHUB_CLIENT_ID
        client_secret: process.env.GITHUB_CLIENT_SECRET
        code: req.query.code
        redirect_uri: process.env.GITHUB_REDIRECT_URI
      headers: headers
      url: 'https://github.com/login/oauth/access_token'
    
    }).then((access_token) ->
      # validate access token response
      access_token = query.parse access_token[0].body
      if access_token.error
        throw new Error "Invalid access token"
      
      # store access token
      req.session.githubSession = access_token
    
      # get user info
      return request.getAsync {
        headers: headers
        url: "https://api.github.com/user?access_token=#{req.session.githubSession.access_token}"
      }
    
    ).then((user) ->
      # validate user response
      user = JSON.parse user[0].body
      if user.error
        throw new Error "Failed to get user info"
      
      # store user info
      req.session.github = user
      
      # get user emails
      return request.getAsync {
        headers: headers
        url: "https://api.github.com/user/emails?access_token=#{req.session.githubSession.access_token}"
      }
    
    ).then((emails) ->
      # validate user emails response
      emails = JSON.parse emails[0].body
      if emails.error
        throw new Error "Failed to get user emails"
      
      # store user emails
      req.session.emails = emails
      
      # get user repos
      return request.getAsync {
        headers: headers
        url: "https://api.github.com/users/crystal/repos?access_token=#{req.session.githubSession.access_token}"
      }
    
    ).then((repos) ->
      # validate user repos response
      repos = JSON.parse repos[0].body
      if repos.error
        throw new Error "Failed to get user repos"
      
      # store user repos
      req.session.repos = repos
      
      # get user by id
      return db.queryAsync({
        TableName: 'User'
        KeyConditions:
          id:
            AttributeValueList: [
              {
                N: req.session.github.id.toString()
              }
            ]
            ComparisonOperator: 'EQ'
      })
      
    ).then((data) ->
      if data.Items.length
        # update user
        return db.updateItemAsync({
          TableName: 'User'
          Key:
            id:
              N: req.session.github.id.toString()
          UpdateExpression: 'SET #A = :avatar, #C = :company, #L = :location, #N = :name, #U = :username, #UR = :url'
          ExpressionAttributeNames:
            '#A': 'avatar'
            '#C': 'company'
            '#L': 'location'
            '#N': 'name'
            '#U': 'username'
            '#UR': 'url'
          ExpressionAttributeValues:
            ':avatar':
              S: req.session.github.avatar_url
            ':company':
              S: req.session.github.company
            ':location':
              S: req.session.github.location
            ':name':
              S: req.session.github.name
            ':username':
              S: req.session.github.login
            ':url':
              S: req.session.github.blog
        })
      else
        # add user
        return db.putItemAsync({
          TableName: 'User'
          Item:
            avatar:
              S: req.session.github.avatar_url
            id:
              N: req.session.github.id.toString()
            username:
              S: req.session.github.login
        })
    
    ).then((data) ->
      repos = []
      i = 0
      for repo in req.session.repos
        if i >= 25
          continue
          
        repos.push {
          PutRequest:
            Item:
              id:
                S: uuid.v4()
              github_id:
                N: repo.id.toString()
              path:
                S: repo.full_name
              url:
                S: repo.html_url
              user:
                N: req.session.github.id.toString()
        }
        
        i++
      
      return db.batchWriteItemAsync({
        RequestItems:
          Repository: repos
      })
    
    ).then((data) ->
      # go back to homepage
      res.redirect '/'
    
    ).catch((e) ->
      res.status(400).send(e.toString() + '. <a href="/login">Try Again</a>')
    )