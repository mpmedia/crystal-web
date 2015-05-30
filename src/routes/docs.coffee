module.exports = (app, title) ->
  app.get '/docs', (req, res) ->
    res.render 'docs', {
      scripts: [
        'scripts/page/docs.js'
      ]
      styles: [
        'styles/page/docs.css'
      ]
      title: title
    }