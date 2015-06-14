aws      = require 'aws-sdk'
bluebird = require 'bluebird'

# scan modules table
db = new aws.DynamoDB({
  region: 'us-east-1'
  endpoint: 'http://localhost:8000'
})

# enable promises
bluebird.promisifyAll Object.getPrototypeOf(db)

forms = require 'forms'
fields = forms.fields
validators = forms.validators

add_collection_form = forms.create {
  name: fields.string({ required: true })
}

add_module_form = forms.create {
  name: fields.string({ required: true })
}

module.exports = (app) ->
  # GET /user
  app.get '/user', (req, res) ->
    if !req.session.github
      res.redirect '/'
    
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
              N: req.session.github.id.toString()
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
        avatar: if req.session.github then req.session.github.avatar_url else null
        company: user_company
        location: user_location
        name: user_name
        repos: req.session.repos
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
        avatar: if req.session.github then req.session.github.avatar_url else null
        company: user_company
        location: user_location
        name: user_name
        repos: req.session.repos
        title: 'Crystal User'
        username: user_username
        url: user_url
      }
    )