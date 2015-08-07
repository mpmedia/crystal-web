formulator = require 'formulator'
Signup = require '../formulas/forms/Signup'
models = require '../models'

module.exports = (app) ->
  
  # GET /
  app.get '/', (req, res) ->
    form = new formulator Signup
    res.render 'home', {
      avatar: req.session.avatar
      form: form
      scripts: [
        'components/codemirror/lib/codemirror.js'
        'components/codemirror/mode/coffeescript/coffeescript.js'
        'components/codemirror/mode/css/css.js'
        'components/codemirror/mode/django/django.js'
        'components/codemirror/mode/dockerfile/dockerfile.js'
        'components/codemirror/mode/go/go.js'
        'components/codemirror/mode/haml/haml.js'
        'components/codemirror/mode/handlebars/handlebars.js'
        'components/codemirror/mode/jade/jade.js'
        'components/codemirror/mode/javascript/javascript.js'
        'components/codemirror/mode/markdown/markdown.js'
        'components/codemirror/mode/nginx/nginx.js'
        'components/codemirror/mode/php/php.js'
        'components/codemirror/mode/puppet/puppet.js'
        'components/codemirror/mode/python/python.js'
        'components/codemirror/mode/ruby/ruby.js'
        'components/codemirror/mode/sass/sass.js'
        'components/codemirror/mode/shell/shell.js'
        'components/codemirror/mode/sql/sql.js'
        'components/codemirror/mode/swift/swift.js'
        'components/codemirror/mode/xml/xml.js'
        'components/codemirror/mode/yaml/yaml.js'
        'components/js-yaml/dist/js-yaml.js'
        'scripts/page/home.js'
      ]
      styles: [
        'components/codemirror/lib/codemirror.css'
        'styles/page/home.css'
        'styles/page/home/contribute.css'
        'styles/page/home/features.css'
        'styles/page/home/generators.css'
        'styles/page/home/intro.css'
        'styles/page/home/usage.css'
      ]
      title: 'Crystal'
    }
