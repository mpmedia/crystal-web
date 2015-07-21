aws = require 'aws-sdk'
bluebird = require 'bluebird'
crypto = require 'crypto'
formulator = require 'formulator'
uuid = require 'uuid'
Signup = require '../formulas/forms/Signup'
models = require '../models'

module.exports = (app) ->
  
  # GET /signup
  app.get '/signup', (req, res) ->
    form = new formulator Signup
    
    res.render 'signup', {
      form: form
      styles: [
        'styles/page/signup.css'
      ]
      title: 'Sign Up | Crystal'
    }
  
  # POST /signup
  app.post '/signup', (req, res) ->
    form = new formulator Signup, req.body
    
    verification = uuid.v4()
    
    bluebird.try () ->
      if !form.isValid()
        throw new Error 'Validation failed.'
    .then () ->
      models.User.findOne {
        where:
          email: form.data.email
      }
    .then (user) ->
      if user
        throw new Error 'Email address in use. Please use another.'
      
      models.User.findOne {
        where:
          username: form.data.username
      }
    .then (user) ->
      if user
        throw new Error 'Username is taken. Please try another.'
        
      models.User.create {
        email: form.data.email
        username: form.data.username
        verification: verification
      }
    .then (user) ->
      avatar_hash = crypto.createHash('md5').update(req.body.email).digest 'hex'
      req.session.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
      req.session.userId = user.dataValues.id
      return user.setPassword req.body.password
    .then (data) ->
      aws.config.accessKeyId = process.env.AWS_SES_USER
      aws.config.secretAccessKey = process.env.AWS_SES_PASS
      
      ses = new aws.SES {
        apiVersion: '2012-10-17'
        region: 'us-east-1'
      }
      bluebird.promisifyAll ses
      to = ["#{req.body.username} <#{req.body.email}>"]
      from = 'Crystal <noreply@crystal.sh>'
      
      ses.sendEmailAsync {
        Source: from
        Destination:
          ToAddresses: to
        Message:
          Subject:
              Data: 'Welcome to Crystal!'
          Body:
            Text:
              Data: "Thank you for signing up! Please verify your account: http://crystal.sh/user/verify/#{verification}"
            Html:
              Data: "Thank you for signing up! Please verify your account: http://crystal.sh/user/verify/#{verification}"
      }
    .then (data) ->
      res.redirect '/'
    .catch (e) ->
      res.render 'signup', {
        error: e.message
        form: form
        styles: [
          'styles/page/signup.css'
        ]
        title: 'Crystal Sign Up'
      }
    
