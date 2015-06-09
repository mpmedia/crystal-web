module.exports = (app) ->
  # DELETE /login/:id
  app.delete '/login/:id', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }
    
  # GET /login/:id?
  app.get '/login/:id?', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }
  
  # PATCH /login/:id
  app.patch '/login/:id', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }
  
  # POST /login/:id
  app.post '/login', (req, res) ->
    res.render 'login', {
      title: 'Crystal Login'
    }

