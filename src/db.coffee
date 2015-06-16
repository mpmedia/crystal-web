bluebird = require 'bluebird'
mysql    = require 'sequelize'

db = {
  models: {}
}

db.connection = new mysql process.env.CRYSTAL_DB, process.env.CRYSTAL_USER, process.env.CRYSTAL_PASS
bluebird.promisifyAll db.connection

db.models.Account = db.connection.define 'account', {
  identifier: mysql.INTEGER
  login: mysql.STRING
}

db.models.Collection = db.connection.define 'collection', {
  name: mysql.STRING
}

db.models.Module = db.connection.define 'module', {
  name: mysql.STRING
}

db.models.Repository = db.connection.define 'repository', {
  url: mysql.STRING
}

db.models.Provider = db.connection.define 'provider', {
  name: mysql.STRING
}

db.models.User = db.connection.define 'user', {
  email: mysql.STRING
  firstName: mysql.STRING
  lastName: mysql.STRING
  location: mysql.STRING
  username: mysql.STRING
}

db.models.Account.belongsTo db.models.Provider
db.models.Account.belongsTo db.models.User
db.models.Collection.belongsTo db.models.User
db.models.Module.belongsTo db.models.Collection
db.models.Module.belongsTo db.models.User
db.models.Repository.belongsTo db.models.User

#db.connection.sync({ force: true })
#  .then (data) ->
#    db.models.Provider.create({
#      name: 'GitHub'
#    })

module.exports = db