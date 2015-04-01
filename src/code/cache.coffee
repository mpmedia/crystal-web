body = require 'body-parser'
cookie = require 'cookie-parser'
express = require 'express'
fs = require 'fs'
jade = require 'jade'
marked = require 'marked'
path = require 'path'
request = require 'request'
sass = require 'node-sass'
session = require 'express-session'

# sync docs
layout_path = "#{__dirname}/views/layout.jade"
content_path = "#{__dirname}/views/docs.jade"
layout = fs.readFileSync layout_path, 'utf8'
content = fs.readFileSync content_path, 'utf8'
html = jade.compile content, { filename: content_path }
fs.writeFileSync "#{__dirname}/public/html/doc.html", html()

# sync css
scss = sass.renderSync {
  file: "#{__dirname}/sass/main.scss"
  outputStyle: 'compressed'
}
fs.writeFileSync "#{__dirname}/public/css/main.css", scss.css

api = "http://127.0.0.1:8080/"

request.get {
  auth: {
    username: 'chris',
    password: 'password'
  },
  url: "#{api}users"
}, (error, response, body) ->
  if !error && response.statusCode == 200
    layout_path = "#{__dirname}/views/layout.jade"
    content_path = "#{__dirname}/views/user.jade"
    layout = fs.readFileSync layout_path, 'utf8'
    content = fs.readFileSync content_path, 'utf8'
    
    users = JSON.parse body
    for user in users
      html = jade.compile content, { filename: content_path }
      fs.writeFileSync "#{__dirname}/public/html/user/#{user.username}.html", html({
        username: user.username
        title: user.username
      })
      
request.get {
  auth: {
    username: 'chris',
    password: 'password'
  },
  url: "#{api}generators"
}, (error, response, body) ->
  if !error && response.statusCode == 200
    layout_path = "#{__dirname}/views/layout.jade"
    content_path = "#{__dirname}/views/gen.jade"
    layout = fs.readFileSync layout_path, 'utf8'
    content = fs.readFileSync content_path, 'utf8'
    
    generators = JSON.parse body
    cacheGenerator = (generator_i) ->
      generator = generators[generator_i]
      
      request.get {
        auth: {
          username: 'chris',
          password: 'password'
        },
        url: "#{api}users/#{generator.user}"
      }, (err, res, bod) ->
        if !err && res.statusCode == 200
          bod = JSON.parse bod
          user = bod.username
        else
          user = 'Unknown'
        
        request.get {
          auth: {
            username: 'chris',
            password: 'password'
          },
          url: "#{api}versions/#{generator.versions[generator.versions.length-1]}"
        }, (err, res, bod) ->
          if !err && res.statusCode == 200
            bod = JSON.parse bod
            version = bod.name
          else
            version = 'Unknown'
          
          if generator.description
            description = marked generator.description
          else
            description = 'No description.'
          
          html = jade.compile content, { filename: content_path }
          fs.writeFileSync "#{__dirname}/public/html/gen/#{generator.name}.html", html({
            name: generator.name
            description: description
            repository_name: if generator.repository_url then generator.repository_url.replace(/^https?:\/\//i, '').replace(/\.git$/i, '') else null
            repository_url: generator.repository_url
            title: generator.name
            user: user
            version: version
            versions: generator.versions.length
          })
          
          generator_i++
          if !generators[generator_i]
            return
          
          cacheGenerator(generator_i)
    
    cacheGenerator(0)