bluebird = require 'bluebird'
request  = require 'request'

# enable promises
bluebird.promisifyAll request

module.exports = (app, db) ->
  # GET /repositories
  app.get '/repositories', (req, res) ->
    # prepare headers
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    db.models.Account.findAll {
      attributes: ['access_token','providerId','uuid']
      where:
        userId: req.session.userId
    }
    .then (accounts_data) ->
      requests = []
      for account in accounts_data
        if account.dataValues.providerId == 1
          requests.push request.getAsync({
            headers: headers
            url: "https://api.github.com/user/repos?access_token=#{account.dataValues.access_token}&per_page=100"
          })
        else if account.dataValues.providerId == 2
          requests.push request.getAsync({
            headers: headers
            url: "https://api.bitbucket.org/2.0/repositories/#{account.dataValues.uuid}?access_token=#{account.dataValues.access_token}"
          })
      
      bluebird.all requests
      .then (results) ->
        repos = []
        for result in results
          result = JSON.parse result[0].body
          
          if result.values[0]
            providerId = 2
            result = result.values
          else
            providerId = 1
          
          for repo in result
            repos.push {
              providerId: providerId
              uuid: repo.id || repo.uuid
              url: repo.html_url || repo.full_name
            }
        
        res.status(200).send repos