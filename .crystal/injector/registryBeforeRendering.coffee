# create form
form = new formulator SearchRegistry, { keywords: req.session.keywords }

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
      color: mod.dataValues.collection.color
      collectionId: mod.dataValues.collection.id
      name: "#{mod.dataValues.collection.name}/#{mod.dataValues.name}"
      type: 'Module'
      user: mod.dataValues.user.username
    }
    
  models.Collection.findAll {
    include:
      model: models.User
      attributes: ['username']
    where: ['name like ?', "%#{req.session.keywords}%"]
  }
  
.then (collections) ->
  for collection in collections
    results.push {
      id: collection.dataValues.id
      color: collection.dataValues.color
      name: collection.dataValues.name
      type: 'Collection'
      user: collection.dataValues.user.username
    }
    
  res.render 'search', {
    avatar: req.session.avatar
    form: form
    keywords: req.session.keywords
    search:
      results: results
    styles: [
      'styles/page/search.css'
    ]
    title: 'Search Crystal'
  }