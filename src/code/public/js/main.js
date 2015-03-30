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