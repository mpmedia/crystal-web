crypto = require 'crypto'

module.exports = (app, db) ->
  # GET /login
  app.get '/login', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }

  # POST /login
  user = {}
  app.post '/login', (req, res) ->
    db.models.User.findOne({
      where:
        username: req.body.username
    })
    .then((user_data) ->
      user = user_data
      return user.verifyPassword req.body.password, user
    )
    .then((validPassword) ->
      if validPassword != true
        return res.status(400).send 'Invalid password'
      
      avatar_hash = crypto.createHash('md5').update(user.dataValues.email).digest 'hex'
      req.session.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
      req.session.userId = user.dataValues.id
      
      res.redirect '/'
    )
    .catch((e) ->
      console.log e
    )