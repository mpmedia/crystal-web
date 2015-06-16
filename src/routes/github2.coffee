bluebird = require 'bluebird'
query    = require 'query-string'
request  = require 'request'
uuid     = require 'node-uuid'

# enable promises
bluebird.promisifyAll request

module.exports = (app, db) ->
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
      return db.models.Account.findOne({
        where:
          identifier: req.session.github.id
      })
      
    ).then((data) ->
      for email in req.session.emails
        if email.primary
          primary_email = email.email
      
      if !primary_email
        throw new Error "No primary email set for GitHub user"
      
      if data
        # update user
        return db.models.Account.update {
          login: req.session.github.login
        },{
          where:
            identifier: req.session.github.id
        }
      else
        # update user
        return db.models.User.create({
          email: primary_email
          location: req.session.github.location
          username: req.session.github.login
        }).then((data) ->
          req.session.userId = data.dataValues.id
          
          return db.models.Account.create({
            identifier: req.session.github.id
            login: req.session.github.login
            providerId: 1
            userId: data.dataValues.id
          })
        )

    ).then((data) ->
      # go back to homepage
      res.redirect '/'
    
    ).catch((e) ->
      res.status(400).send(e.toString() + '. <a href="/login">Try Again</a>')
    )