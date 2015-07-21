bluebird = require 'bluebird'
bcrypt   = require 'bcrypt'
mysql    = require 'sequelize'

db = require './models'

reset = () ->
  db.sequelize.sync({ force: true })
  .then (data) ->
    db.Provider.create {
      name: 'GitHub'
    }
    db.Provider.create {
      name: 'Bitbucket'
    }

#reset()

module.exports = db