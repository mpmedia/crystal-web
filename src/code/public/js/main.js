var api = 'http://127.0.0.1:8080/';

var login = function() {
  $.ajax({
    method: 'POST',
    url: api + 'login',
    data: {
      username: $('input[name="username"]').val(),
      password: $('input[name="password"]').val()
    },
    success: function(data) {
      console.log(data);
    }
  });
  
  return false;
};

var search = function() {
  $('#results').empty();
  
  if (!$('input[name="search"]').val().length) {
    return;
  }
  
  $.ajax({
    method: 'GET',
    url: api + 'generators',
    success: function(data) {
      $('#results').empty();
      
      if (!$('input[name="search"]').val().length) {
        return;
      }
      
      var gen;
      for (var i in data) {
        if (i == 10) {
          break;
        }
        gen = data[i];
        $('#results').append('<a href="gen/' + gen.name + '.html">' + gen.name + '</a>')
      }
      
      console.log(data);
    }
  });
};

var signup = function() {
  $.ajax({
    method: 'POST',
    url: api + 'users',
    data: {
      email: $('input[name="email"]').val(),
      username: $('input[name="username"]').val(),
      password: $('input[name="password"]').val()
    },
    success: function(data) {
      console.log(data);
    }
  });
  
  return false;
};