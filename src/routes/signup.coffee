crypto = require 'crypto'

module.exports = (app, db) ->
  # POST /signup
  app.post '/signup', (req, res) ->
    db.models.User.create({
      email: req.body.email
      username: req.body.username
    })      
    .then (user) ->
      avatar_hash = crypto.createHash('md5').update(req.body.email).digest 'hex'
      req.session.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
      req.session.userId = user.dataValues.id
      return user.setPassword req.body.password
    .then (data) ->
      res.redirect '/'