crypto = require 'crypto'
formulator = require '/Users/ctate/.crystal/dev/formulator'

Login = require '../formulas/forms/Login'

module.exports = (app, db) ->
  # GET /login
  app.get '/login', (req, res) ->
    if req.session.userId
      res.redirect '/user'
    
    form = new formulator Login
    
    res.render 'login', {
      form: form
      styles: [
        'styles/page/login.css'
      ]
      title: 'Crystal Login'
    }

  # POST /login
  user = {}
  app.post '/login', (req, res) ->
    form = new formulator Login, req.body
    
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
      
      if req.header('Referer') && !req.header('Referer').match('/login')
        url = req.header('Referer')
      else
        url = '/'
        
      res.redirect url
    )
    .catch((e) ->
      res.render 'login', {
        form: form
        error: e
        styles: [
          'styles/page/login.css'
        ]
        username: req.body.username
        title: 'Crystal Login'
      }
    )