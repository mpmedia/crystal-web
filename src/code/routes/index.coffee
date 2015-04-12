module.exports = (app, title) ->
  app.get '/', (req, res) ->
    res.render 'index', {
      scripts: [
        'scripts/page/index.js'
      ]
      styles: [
        'styles/page/index.css'
      ]
      title: title
    }