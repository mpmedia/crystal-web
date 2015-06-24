bluebird = require 'bluebird'
bcrypt   = require 'bcrypt'
mysql    = require 'sequelize'

db = {
  models: {}
}

db.connection = new mysql process.env.CRYSTAL_DB, process.env.CRYSTAL_USER, process.env.CRYSTAL_PASS
bluebird.promisifyAll db.connection

db.models.Account = db.connection.define 'account', {
  identifier: mysql.INTEGER
  login: mysql.STRING
  token: mysql.STRING
}

db.models.Collection = db.connection.define 'collection', {
  color: mysql.STRING 6
  name:
    unique: true
    type: mysql.STRING
}

db.models.Module = db.connection.define 'module', {
  name: mysql.STRING
}

db.models.Repository = db.connection.define 'repository', {
  identifier: mysql.STRING
  path: mysql.STRING
  url: mysql.STRING
}

db.models.Provider = db.connection.define 'provider', {
  name: mysql.STRING
}

db.models.User = db.connection.define 'user', {
  company: mysql.STRING
  email:
    type: mysql.STRING
    unique: true
  firstName: mysql.STRING
  lastName: mysql.STRING
  location: mysql.STRING
  username:
    type: mysql.STRING
    unique: true
  password: mysql.STRING
  verification: mysql.STRING
  verifiedAt: mysql.DATE
},{
  instanceMethods:
    setPassword: (password) ->
      salt = bcrypt.genSaltSync 10
      this.password = bcrypt.hashSync password, salt
      this.save()
    verifyPassword: (password) ->
      bcrypt.compareSync password, this.password
}

db.models.Account.belongsTo db.models.Provider
db.models.Account.belongsTo db.models.User
db.models.Collection.belongsTo db.models.User
db.models.Module.belongsTo db.models.Collection
db.models.Module.belongsTo db.models.Repository
db.models.Module.belongsTo db.models.User
db.models.Repository.belongsTo db.models.Provider
db.models.Repository.belongsTo db.models.User

db.reset = () ->
  db.connection.sync({ force: true })
    .then (data) ->
      db.models.Provider.create({
        name: 'GitHub'
      })
      db.models.Provider.create({
        name: 'Bitbucket'
      })

#db.reset()

module.exports = db