bluebird = require 'bluebird'
uuid     = require 'node-uuid'

module.exports = (app, db) ->
  # POST /collections
  app.post '/collections', (req, res) ->
    db.models.Collection.findOne({
      where:
        name: req.body.name
    })
    .then((data) ->
      if data
        res.status(400).send('Duplicate')
        return
      
      return db.models.Collection.create({
        name: req.body.name
        userId: req.session.userId
      })
    )
    .then((data) ->
      console.log data
      res.redirect '/user'
    )