module.exports = (app, title) ->
  app.get '/', (req, res) ->
    res.render 'home', {
      title: 'Crystal'
    }