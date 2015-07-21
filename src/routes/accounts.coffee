models = require '../models'

module.exports = (app) ->
  
  # GET /accounts
  app.get '/accounts', (req, res) ->
    accounts = models.Account.findAll {
      attributes: ['id','login']
      where:
        UserId: req.session.userId
    }
    .then (accounts_data) ->
      accounts = []
      for account in accounts_data
        accounts.push account.dataValues
      
      res.status(200).send accounts
    
