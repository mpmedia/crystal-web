module.exports = (app, title) ->
  app.get '/generators', (req, res) ->
    res.render 'generators', {
      scripts: [
        'scripts/page/generators.js'
      ]
      styles: [
        'styles/page/generators.css'
      ]
      title: title
    }