module.exports = (app, title) ->
  app.get '/help', (req, res) ->
    res.render 'help', {
      scripts: [
        'scripts/page/help.js'
      ]
      styles: [
        'styles/page/help.css'
      ]
      title: title
    }