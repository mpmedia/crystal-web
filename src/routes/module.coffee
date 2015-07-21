models = require '../models'

module.exports = (app) ->
  
  # GET /module/:name
  app.get '/module/:name', (req, res) ->
    Module.remove { _id: req.params.id }, (err, result) ->
      if err
        res.status(400).send err
        return
      res.status(200).send {}
