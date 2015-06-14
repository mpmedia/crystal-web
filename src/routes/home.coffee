module.exports = (app) ->
  # GET /
  app.get '/', (req, res) ->
    res.render 'home', {
      avatar: if req.session.github then req.session.github.avatar_url else null
      clientID: process.env.GITHUB_CLIENT_ID
      redirectURI: process.env.GITHUB_REDIRECT_URI
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
