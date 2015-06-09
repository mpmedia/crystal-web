module.exports = (app) ->
  # DELETE /user/:id
  app.delete '/user/:id', (req, res) ->
    res.render 'user', {
      title: 'Crystal User'
    }
    
  # GET /user/:id?
  app.get '/user/:id?', (req, res) ->
    res.render 'user', {
      title: 'Crystal User'
    }
  
  # PATCH /user/:id
  app.patch '/user/:id', (req, res) ->
    res.render 'user', {
      title: 'Crystal User'
    }
  
  # POST /user/:id
  app.post '/user', (req, res) ->
    res.render 'user', {
      title: 'Crystal User'
    }

