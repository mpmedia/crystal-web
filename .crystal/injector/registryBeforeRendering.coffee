# create form
form = new formulator SearchRegistry, { keywords: req.query.keywords }

results = []
models.Module.findAll {
  include: [
    {
      model: models.Collection
      attributes: ['id','color','name']
    }
    {
      model: models.User
      attributes: ['username']
    }
  ]
  where: ['module.name like ?', "%#{req.query.keywords}%"]
}

.then (modules) ->
  for mod in modules
    results.push {
      id: mod.dataValues.id
      color: mod.dataValues.Collection.color
      name: "#{mod.dataValues.Collection.name}/#{mod.dataValues.name}"
      type: 'Module'
      user: mod.dataValues.User.username
      CollectionId: mod.dataValues.Collection.id
    }
    
  models.Collection.findAll {
    include:
      model: models.User
      attributes: ['username']
    where: ['name like ?', "%#{req.query.keywords}%"]
  }
  
.then (collections) ->
  for collection in collections
    results.push {
      id: collection.dataValues.id
      color: collection.dataValues.color
      name: collection.dataValues.name
      type: 'Collection'
      user: collection.dataValues.User.username
    }
    
  res.render 'search', {
    avatar: req.session.avatar
    form: form
    keywords: req.query.keywords
    search:
      results: results
    styles: [
      'styles/page/search.css'
    ]
    title: 'Search Crystal'
  }

.catch (e) ->
  res.render 'error', {
    error: e
    title: 'Error | Crystal'
  }