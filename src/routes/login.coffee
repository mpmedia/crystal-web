crypto = require 'crypto'

module.exports = (app, db) ->
  # GET /login
  app.get '/login', (req, res) ->
    res.render 'login', {
      styles: [
        'styles/page/login.css'
      ]
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
      if !user_data
        throw new Error 'Unknown user. Did you mean to <a href="signup">Sign Up?</a>'
        
      user = user_data
      return user.verifyPassword req.body.password, user
    )
    .then((validPassword) ->
      if validPassword != true
        throw new Error "Invalid username/password."
      
      avatar_hash = crypto.createHash('md5').update(user.dataValues.email).digest 'hex'
      req.session.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
      req.session.userId = user.dataValues.id
      
      url = req.header('Referer') or '/'
      res.redirect url
    )
    .catch((e) ->
      res.render 'login', {
        error: e
        styles: [
          'styles/page/login.css'
        ]
        username: req.body.username
        title: 'Crystal Login'
      }
    )