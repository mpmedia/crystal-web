bluebird = require 'bluebird'
crypto   = require 'crypto'

forms = require 'forms'
fields = forms.fields
validators = forms.validators
widgets = forms.widgets

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
      
      add_collection_form = forms.create {
        name: fields.string({ required: true })
      }

      add_module_form = forms.create {
        name: fields.string({ required: true })
        repository: fields.url({
          choices: repo_choices
          required: true
          widget: widgets.select()
        })
      }
      
      avatar_hash = crypto
        .createHash('md5')
        .update(user_email)
        .digest 'hex'
      
      res.render 'user', {
        add_collection_form: add_collection_form.toHTML()
        add_module_form: add_module_form.toHTML()
        avatar: "http://www.gravatar.com/avatar/#{avatar_hash}"
        collections: collections
        company: user_company
        location: user_location
        name: user_name
        repos: repos
        title: 'Crystal User'
        username: user_username
        url: user_url
      }
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