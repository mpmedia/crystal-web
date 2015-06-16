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
  
  # GET /user/:id
  app.get '/user/:id', (req, res) ->
    user_id = ""
    user_company = ""
    user_location = ""
    user_name = ""
    user_url = ""
    user_username = ""
    db.queryAsync({
      TableName: 'User'
      KeyConditions:
        id:
          AttributeValueList: [
            {
              N: req.params.id.toString()
            }
          ]
          ComparisonOperator: 'EQ'
          
    }).then((user) ->
      user_id = user.Items[0].id.N
      user_company = user.Items[0].company.S
      user_location = user.Items[0].location.S
      user_name = user.Items[0].name.S
      user_url = user.Items[0].url.S
      user_username = user.Items[0].username.S
      
      return db.queryAsync({
        TableName: 'Collection'
        IndexName: 'UserIndex'
        KeyConditions:
          user:
            AttributeValueList: [
              {
                N: user_id
              }
            ]
            ComparisonOperator: 'EQ'
      })
    
    ).then((collections) ->
      return db.queryAsync({
        TableName: 'Module'
        IndexName: 'UserIndex'
        KeyConditions:
          user:
            AttributeValueList: [
              {
                N: user_id
              }
            ]
            ComparisonOperator: 'EQ'
      })
    
    ).then((modules) ->
      res.render 'user', {
        add_collection_form: add_collection_form.toHTML()
        add_module_form: add_module_form.toHTML()
        company: user_company
        location: user_location
        name: user_name
        repos: req.session.repos
        title: 'Crystal User'
        username: user_username
        url: user_url
      }
    )