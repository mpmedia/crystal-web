bluebird = require 'bluebird'
request = require 'request'
# enable promises
bluebird.promisifyAll request

sortByKey = (array, key) ->
  array.sort (a, b) ->
    x = a[key]
    y = b[key]
    if typeof x == 'string'
      x = x.toLowerCase()
      y = y.toLowerCase()
    if x < y then -1 else if x > y then 1 else 0

models = require '../models'

module.exports = (app) ->
  
  # GET /repositories
  app.get '/repositories', (req, res) ->
    # prepare headers
    headers = {
      'User-Agent': 'Crystal <support@crystal.sh> (https://crystal.sh)'
    }
    
    models.Account.findAll {
      attributes: ['accessToken','ProviderId','uuid']
      where:
        userId: req.session.userId
    }
    .then (accounts_data) ->
      requests = []
      for account in accounts_data
        # get url for request
        url = switch account.dataValues.ProviderId
          when 1
            "https://api.github.com/user/repos?access_token=#{account.dataValues.accessToken}&per_page=100"
          when 2
            "https://api.bitbucket.org/2.0/repositories/#{account.dataValues.uuid}?access_token=#{account.dataValues.accessToken}"      
        
        # get account repos
        requests.push request.getAsync {
          headers: headers
          url: url
        }
      
      bluebird.all requests
      .then (results) ->
        repos = []
        for result in results
          if result[0].statusCode != 200
            throw new Error 'Unable to fetch repositories'
            
          result = JSON.parse result[0].body
          
          if result.values and result.values[0]
            providerId = 2
            result = result.values
          else
            providerId = 1
          
          for repo in result
            repos.push {
              providerId: providerId
              uuid: repo.id || repo.uuid
              url: repo.full_name
            }
        console.log repos
        sortByKey repos, 'url'
        
        res.status(200).send repos
    .catch (e) ->
      res.status(400).send { error: e.toString() }
