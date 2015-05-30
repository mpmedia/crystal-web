var app, body, cookie, express, fs, path, session, title;

body = require('body-parser');

cookie = require('cookie-parser');

express = require('express');

fs = require('fs');

path = require('path');

session = require('express-session');

app = express();

title = 'Crystal - Open Source Code Generator for Every Language and Platform';

app.set('views', path.join(__dirname, 'views'));

app.set('view engine', 'jade');

app.use('/font', express["static"](__dirname + "/public/font"));

app.use('/images', express["static"](__dirname + "/public/images"));

app.use('/scripts', express["static"](__dirname + "/public/js"));

app.use('/styles', express["static"](__dirname + "/public/css"));

app.use(body());

app.use(cookie());

app.use(session({
    secret: 'PhKbgxBJjBOlAylyzeaBilyXdV0GfoQi'
}));

require('0')(app, title);

require('1')(app, title);

require('2')(app, title);

require('3')(app, title);

require('4')(app, title);

require('5')(app, title);

require('6')(app, title);

console.log('Serving...');

app.listen(80);