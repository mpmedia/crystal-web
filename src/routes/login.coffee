module.exports = (app, db) ->
  # GET /login
  app.get '/login', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }

  # POST /login
  app.post '/login', (req, res) ->
    db.models.User.create({
      email: req.query.email
      username: req.query.username
    })      
    .then (data) ->
      req.session.userId = data.dataValues.id
      return db.models.User.setPassword req.query.password
    .then (data) ->
      res.redirect '/'