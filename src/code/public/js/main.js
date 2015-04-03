var api = 'https://api.crystal.sh/';

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

var search_i = 0;
var search_terms = [
  'laravel',
  'datamapper',
  'pip',
  'authors',
  'gorm',
  'readme',
  'sinatra',
  'ormlite',
  'gorp',
  'django'
];

$(window).load(function() {
  $('.lang-html, .lang-ruby, .lang-yaml, .lang-sh').addClass('prettyprint');
  prettyPrint();
  
  setInterval(function() {
    var search_term = search_terms[search_i];
    $('#search-term').attr('href', '/gen/' + search_term);
    $('#search-term').text(search_term);
    
    if (search_i == search_terms.length-1) {
      search_i = 0;
    } else {
      search_i++;
    }
    
  }, 2000);
});