module.exports = (app) ->
  # DELETE /hub/:id
  app.delete '/hub/:id', (req, res) ->
    res.render 'hub', {
      title: 'Crystal Hub'
    }
    
  # GET /hub/:id?
  app.get '/hub/:id?', (req, res) ->
    res.render 'hub', {
      title: 'Crystal Hub'
    }
  
  # PATCH /hub/:id
  app.patch '/hub/:id', (req, res) ->
    res.render 'hub', {
      title: 'Crystal Hub'
    }
  
  # POST /hub/:id
  app.post '/hub', (req, res) ->
    res.render 'hub', {
      title: 'Crystal Hub'
    }

