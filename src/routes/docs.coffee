module.exports = (app) ->
  # DELETE /docs/:id
  app.delete '/docs/:id', (req, res) ->
    res.render 'docs', {
      title: 'Crystal Docs'
    }
    
  # GET /docs/:id?
  app.get '/docs/:id?', (req, res) ->
    res.render 'docs', {
      title: 'Crystal Docs'
    }
  
  # PATCH /docs/:id
  app.patch '/docs/:id', (req, res) ->
    res.render 'docs', {
      title: 'Crystal Docs'
    }
  
  # POST /docs/:id
  app.post '/docs', (req, res) ->
    res.render 'docs', {
      title: 'Crystal Docs'
    }

