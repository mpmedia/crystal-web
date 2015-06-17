aws      = require 'aws-sdk'
bluebird = require 'bluebird'
crypto   = require 'crypto'
uuid     = require 'node-uuid'

aws.config.accessKeyId = process.env.AWS_SES_USER
aws.config.secretAccessKey = process.env.AWS_SES_PASS

module.exports = (app, db) ->
  # GET /signup
  app.get '/signup', (req, res) ->
    res.render 'signup', {
      styles: [
        'styles/page/signup.css'
      ]
      title: 'Crystal Sign Up'
    }
    
  # POST /signup
  app.post '/signup', (req, res) ->
    verification = uuid.v4()
    
    db.models.User.create({
      email: req.body.email
      username: req.body.username
      verification: verification
    })      
    .then (user) ->
      avatar_hash = crypto.createHash('md5').update(req.body.email).digest 'hex'
      req.session.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
      req.session.userId = user.dataValues.id
      return user.setPassword req.body.password
    .then (data) ->
      ses = new aws.SES({
        apiVersion: '2012-10-17'
        region: 'us-east-1'
      })
      bluebird.promisifyAll ses
      to = ["#{req.body.username} <#{req.body.email}>"]
      from = 'Crystal <noreply@crystal.sh>'
      
      ses.sendEmailAsync({
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
      })
      .then((data) ->
        console.log data
      )
      .catch((e) ->
        console.log e
      )
      
      res.redirect '/'