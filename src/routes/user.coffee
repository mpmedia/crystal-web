bluebird   = require 'bluebird'
crypto     = require 'crypto'
formulator = require '/Users/ctate/.crystal/dev/formulator'

EditUser = require '../forms/EditUser'

module.exports = (app, db) ->
  # GET /user
  app.get '/user', (req, res) ->
    if !req.session.userId
      res.redirect '/'
    
    collections = []
    user_id = ""
    user_company = ""
    user_email = ""
    user_location = ""
    user_name = ""
    user_url = ""
    user_username = ""
    db.models.User.findOne({
      where:
        id: req.session.userId
    }).then((user) ->
      if !user
        throw new Error "Please login"
      
      user_id = user.dataValues.id
      user_company = user.dataValues.company
      user_email = user.dataValues.email
      user_location = user.dataValues.location
      user_name = user.dataValues.name
      user_url = user.dataValues.url
      user_username = user.dataValues.username
      
      return db.models.Collection.findAll({
        where:
          userId: req.session.userId
      })
    
    ).then((collections_data) ->
      collections = []
      for collection in collections_data
        collections.push collection.dataValues
      
      console.log collections
      
      return db.models.Module.findAll({
        where:
          userId: req.session.userId
      })
    
    ).then((modules) ->
      return db.models.Repository.findAll({
        where:
          userId: req.session.userId
      })
      
    ).then((repository_data) ->
      repo_choices = []
      repos = []
      if repository_data.length
        for repo in repository_data
          repo_choices[repo.id.S] = repo.url.S
          repos.push {
            url: repo.url.S
          }
            
      avatar_hash = crypto
        .createHash('md5')
        .update(user_email)
        .digest 'hex'
      
      res.render 'user', {
        avatar: req.session.avatar
        collections: collections
        company: user_company
        location: user_location
        name: user_name
        repos: repos
        scripts: [
          'scripts/field/Color.js'
          'scripts/form/AddCollection.js'
          'scripts/form/EditCollection.js'
          'scripts/form/DeleteCollection.js'
          'scripts/page/user.js'
        ]
        styles: [
          'styles/page/user.css'
        ]
        title: 'Crystal User'
        unverified: true
        username: user_username
        url: user_url
      }
    )
  
  # GET /user/edit
  app.get '/user/edit', (req, res) ->
    db.models.User.findOne({
      where:
        id: req.session.userId
    })
    .then((user) ->
      if !user
        res.status(400).send('Verification failed')
        return
      
      form = new formulator EditUser, user.dataValues
      
      res.render 'edit', {
        form: form.toString()
        styles: [
          'styles/page/user.css'
        ]
        title: 'Crystal User'
        url: user.dataValues.url
      }
    )
  
  # POST /user/edit
  app.post '/user/edit', (req, res) ->
    form = new formulator EditUser, req.body
    
    if !form.isValid()
      res.status(400).send('Validation failed')
      return
    
    db.models.User.update({
      location: req.body.location
    },{
      where:
        id: req.session.userId
    })
    .then((user) ->
      if !user
        res.status(400).send('Update failed')
        return
      
      res.redirect '/user/edit'
    )
  
  # GET /user/verify
  app.get '/user/verify/:verification', (req, res) ->
    db.models.User.findOne({
      where:
        verification: req.params.verification
    })
    .then((user) ->
      if !user
        res.status(400).send('Verification failed')
        return
      
      user.verification = null
      user.verifiedAt = new Date
      user.save()
      
      res.redirect '/'
    )