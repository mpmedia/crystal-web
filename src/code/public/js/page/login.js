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
  $('input, button').prop('disabled', true);
  $('button').text('Loading...');
  $('form .error').hide();
  
  $.ajax({
    method: 'POST',
    url: api + 'users',
    data: {
      email: $('input[name="email"]').val(),
      username: $('input[name="username"]').val(),
      password: $('input[name="password"]').val()
    },
    error: function(data) {
      if (data.responseText && data.responseText.match('duplicate')) {
        if (data.responseText.match('email')) {
          $('form .error').text('Email is in use. Please try another.').show();
        } else {
          $('form .error').text('Username is taken. Please try another.').show();
        }
      } else {
        $('form .error').text('Unable to signup. Please try again.').show();
      }
      
      $('input, button').prop('disabled', false);
      $('button').text('Sign Up');
    },
    success: function(data) {
      $('form').hide();
      $('#success').show();
    }
  });
  
  return false;
};