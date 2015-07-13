{{#equals @key 'post'}}
form = new formulator Login, req.body

db.models.User.findOne {
  where:
    username: req.body.username
}
.then (user_data) ->
  if !user_data
    throw new Error 'Unknown user. Did you mean to <a href="signup">Sign Up?</a>'
    
  user = user_data
  return user.verifyPassword req.body.password, user

.then (validPassword) ->
  if validPassword != true
    throw new Error "Invalid username/password."
  
  avatar_hash = crypto.createHash('md5').update(user.dataValues.email).digest 'hex'
  req.session.avatar = "http://www.gravatar.com/avatar/#{avatar_hash}"
  req.session.userId = user.dataValues.id
  
  if req.header('Referer') && !req.header('Referer').match('/login')
    url = req.header('Referer')
  else
    url = '/'
    
  res.redirect url

.catch (e) ->
  res.render 'login', {
    form: form
    error: e
    styles: [
      'styles/page/login.css'
    ]
    username: req.body.username
    title: 'Crystal Login'
  }
{{/equals}}