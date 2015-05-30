module.exports = (app, title) ->
  app.get '/', (req, res) ->
    res.render 'index', {
      scripts: [
        'scripts/page/index.js'
      ]
      styles: [
        'styles/page/index.css'
        'styles/page/index/contribute.css'
        'styles/page/index/features.css'
        'styles/page/index/generators.css'
        'styles/page/index/intro.css'
        'styles/page/index/usage.css'
      ]
      title: title
    }