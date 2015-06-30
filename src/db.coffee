bluebird = require 'bluebird'
bcrypt   = require 'bcrypt'
mysql    = require 'sequelize'

db = {
  models: {}
}

db.connection = new mysql process.env.CRYSTAL_DB, process.env.CRYSTAL_USER, process.env.CRYSTAL_PASS
bluebird.promisifyAll db.connection

db.models.Account = db.connection.define 'account', {
  access_token: mysql.STRING
  login: mysql.STRING
  refresh_token: mysql.STRING
  uuid: mysql.STRING
}

db.models.Collection = db.connection.define 'collection', {
  description: mysql.STRING
  color: mysql.STRING 6
  favorites: mysql.INTEGER
  rating: mysql.DECIMAL 10, 2
  name:
    unique: true
    type: mysql.STRING
  website: mysql.STRING
}

db.models.FavoriteCollection = db.connection.define 'favorite_collection', {
}

db.models.FavoriteModule = db.connection.define 'favorite_module', {
}

db.models.Module = db.connection.define 'module', {
  description: mysql.STRING
  #favorites: mysql.INTEGER
  name: mysql.STRING
  rating: mysql.DECIMAL 10, 2
}

db.models.ModuleRating = db.connection.define 'module_rating', {
  rating: mysql.INTEGER 1
}

db.models.Repository = db.connection.define 'repository', {
  path: mysql.STRING
  url: mysql.STRING
  uuid: mysql.STRING
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
  website: mysql.STRING
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
db.models.FavoriteCollection.belongsTo db.models.Collection
db.models.FavoriteCollection.belongsTo db.models.User
db.models.FavoriteModule.belongsTo db.models.Module
db.models.FavoriteModule.belongsTo db.models.User
db.models.Module.belongsTo db.models.Account
db.models.Module.belongsTo db.models.Collection
db.models.Module.belongsTo db.models.Repository
db.models.Module.belongsTo db.models.User
db.models.ModuleRating.belongsTo db.models.Module
db.models.ModuleRating.belongsTo db.models.User
db.models.Repository.belongsTo db.models.Account
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