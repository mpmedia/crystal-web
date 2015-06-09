module.exports = (app) ->
  # DELETE /help/:id
  app.delete '/help/:id', (req, res) ->
    res.render 'help', {
      title: 'Crystal Help'
    }
    
  # GET /help/:id?
  app.get '/help/:id?', (req, res) ->
    res.render 'help', {
      title: 'Crystal Help'
    }
  
  # PATCH /help/:id
  app.patch '/help/:id', (req, res) ->
    res.render 'help', {
      title: 'Crystal Help'
    }
  
  # POST /help/:id
  app.post '/help', (req, res) ->
    res.render 'help', {
      title: 'Crystal Help'
    }

