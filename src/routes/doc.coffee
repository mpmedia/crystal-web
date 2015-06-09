module.exports = (app) ->
  # DELETE /doc/:id
  app.delete '/doc/:id', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }
    
  # GET /doc/:id?
  app.get '/doc/:id?', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }
  
  # PATCH /doc/:id
  app.patch '/doc/:id', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }
  
  # POST /doc/:id
  app.post '/doc', (req, res) ->
    res.render 'doc', {
      title: 'Crystal Doc'
    }

