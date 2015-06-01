route = (app, title) ->
  app.get '/', (req, res) ->
    res.render 'home', {
      scripts: [
        'scripts/page/home.js'
      ]
      styles: [
        'styles/page/home.css'
        'styles/page/home/contribute.css'
        'styles/page/home/features.css'
        'styles/page/home/generators.css'
        'styles/page/home/intro.css'
        'styles/page/home/usage.css'
      ]
      title: 'Crystal'
    }
    
module.exports = route