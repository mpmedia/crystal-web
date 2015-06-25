bluebird = require 'bluebird'
query    = require 'query-string'
request  = require 'request'

# enable promises
bluebird.promisifyAll request

module.exports = (app, db) ->
  # GET /accounts/connect/:provider
  app.get '/accounts/connect/:provider', (req, res) ->
    # require code from provider
    if !req.query.code
      throw new Error "Code is required"
    
    # prepare headers for github
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    # collect data
    data = {}
    
    # get provider by name
    provider = db.models.Provider.findOne {
      where:
        name: req.params.provider
    }
    
    .then (provider) ->
      # provider does not exist
      if !provider
        throw new Error 'Unknown provider'
      
      # collect provider
      data.provider = provider.dataValues.id
      
      # login to provider
      if data.provider == 1
        request.postAsync {
          form:
            client_id: process.env.GITHUB_CLIENT_ID
            client_secret: process.env.GITHUB_CLIENT_SECRET
            code: req.query.code
            redirect_uri: process.env.GITHUB_REDIRECT_URI
          headers: headers
          url: 'https://github.com/login/oauth/access_token'
        }
      else if data.provider == 2
        request.postAsync {
          auth:
            user: process.env.BITBUCKET_CLIENT_ID
            pass: process.env.BITBUCKET_CLIENT_SECRET
          form:
            code: req.query.code
            grant_type: 'authorization_code'
          headers: headers
          url: 'https://bitbucket.org/site/oauth2/access_token'
        }
      else
        throw new Error 'Invalid provider'
    
    .then (access_token) ->
      # validate access token response
      if data.provider == 1
        access_token = query.parse access_token[0].body
      else if data.provider == 2
        access_token = JSON.parse access_token[0].body
      if access_token.error
        throw new Error "Invalid access token"
      
      # collect token
      data.token = access_token.access_token
      
      # get user info
      if data.provider == 1
        request.getAsync {
          headers: headers
          url: "https://api.github.com/user?access_token=#{data.token}"
        }
      else if data.provider == 2
        request.getAsync {
          headers: headers
          url: "https://api.bitbucket.org/2.0/user?access_token=#{data.token}"
        }
    
    .then (user) ->
      # validate user response
      user = JSON.parse user[0].body
      if user.error
        throw new Error "Failed to get user info"
      
      # create account
      account = db.models.Account.create {
        login: user.login || user.username
        providerId: data.provider
        token: data.token
        userId: req.session.userId
        uuid: user.id || user.uuid
      }
      
      res.redirect '/user'
      
    .catch (e) ->
      res.render 'error', {
        error: 'Unable to connect account. Please try again.'
        title: 'Error | Crystal'
      }