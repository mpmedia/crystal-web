app.use (req, res, next) ->
  
  if req.host.match('hub\.crystal\.sh')
    # get collection/module name
    if req.url.match('\\.')
      url = req.url.split '\.'
      collection_name = url[0].substr 1
      module_name = url[1]
    else
      url = req.url.split '/'
      collection_name = url[1]
      module_name = url[2]
    
    # collect data
    data = {}
    
    if module_name and module_name.length
      bluebird.try () ->
        models.Collection.findOne {
          attributes: ['id','name']
          where:
            name: collection_name
        }

      .then (collection_data) ->
        if !collection_data
          throw new Error "Collection does not exist: #{collection_name}"
        
        data.collection = collection_data.dataValues
        
        models.Module.findOne {
          include:
            attributes: ['id','path','uuid']
            model: models.Repository
            include:
              attributes: ['id','accessToken']
              model: models.Account
          where:
            CollectionId: data.collection.id
            name: module_name
        }

      .then (module_data) ->
        if !module_data
          throw new Error "Module does not exist: #{module_name}"
        
        data.module = module_data.dataValues
        data.repository = data.module.Repository.dataValues
        data.account = data.repository.Account.dataValues
        
        res.render 'module', {
          account: data.account
          avatar: req.session.avatar
          collection: data.collection
          module: data.module
          repository: data.repository
          scripts: [
            'scripts/page/module.js'
          ]
          styles: [
            'styles/page/module.css'
          ]
        }
          
      .catch (e) ->
        res.render 'error', {
          avatar: req.session.avatar
          error: e.toString()
        }
      
    else
      bluebird.try () ->
        models.Collection.findOne {
          include:
            attributes: ['id','username']
            model: models.User
          where:
            name: collection_name
        }
        
      .then (collection_data) ->
        data.collection = collection_data.dataValues
        
        models.Module.findAll {
          include: [
            {
              attributes: ['id','path','uuid']
              model: models.Repository
            }
            {
              attributes: ['username']
              model: models.User
            }
          ]
          where:
            CollectionId: data.collection.id
        }
      
      .then (modules_data) ->
        data.collection.modules = []
        for module in modules_data
          data.collection.modules.push {
            id: module.dataValues.id
            description: module.dataValues.description
            name: module.dataValues.name
            repository: module.dataValues.Repository.path
            username: module.dataValues.User.dataValues.username
          }
        
        models.FavoriteCollection.findOne {
          where:
            CollectionId: data.collection.id
            UserId: req.session.userId
        }
        
      .then (favorite_data) ->
        if favorite_data
          data.collection.favorite = true
        
        res.render 'collection', {
          avatar: req.session.avatar
          collection: data.collection
          scripts: [
            'scripts/page/collections.js'
          ]
          styles: [
            'styles/page/collection.css'
          ]
          title: "#{data.collection.name} Collection | Crystal"
        }
        
      .catch (e) ->
        res.status 404
        res.render '404', {
          avatar: req.session.avatar
          styles: [
            'styles/page/404.css'
          ]
          url: req.url
        }
        
    return
  
  res.status 404
  res.render 'error', {
    error: 'Page Not Found'
  }