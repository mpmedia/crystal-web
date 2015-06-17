var api = 'https://api.crystal.sh/';

$(window).load(function() {
  $('.login').click(function() {
    var overlay = $('<div id="overlay" />');
    overlay.click(function() {
      $('#overlay, #popup').remove();
    });
    $('body').append(overlay);
    
    var popup = $('<div id="popup" />')
    popup.append('<h1>Please Login</h1>');
    popup.append(''
      + '<form action="/login" method="post">'
        + '<div>'
          + '<label>Username</label>'
          + '<input name="username" type="text" />'
        + '</div>'
        + '<div>'
          + '<label>Password</label>'
          + '<input name="password" type="password" />'
        + '</div>'
        + '<input type="submit" value="Login" />'
      + '</form>'
    );
    $('body').append(popup);
    
    $(window).resize();
    
    $('#popup input').first().focus();
    
    return false;
  });
  
  $('.signup').click(function() {
    var overlay = $('<div id="overlay" />');
    overlay.click(function() {
      $('#overlay, #popup').remove();
    });
    $('body').append(overlay);
    
    var popup = $('<div id="popup" />')
    popup.append('<h1>Sign Up</h1>');
    popup.append(''
      + '<form action="/signup" method="post">'
        + '<div>'
          + '<label>Username</label>'
          + '<input name="username" type="text" />'
        + '</div>'
        + '<div>'
          + '<label>Email</label>'
          + '<input name="email" type="text" />'
        + '</div>'
        + '<div>'
          + '<label>Password</label>'
          + '<input name="password" type="password" />'
        + '</div>'
        + '<input type="submit" value="Signup" />'
      + '</form>'
    );
    $('body').append(popup);
    
    $(window).resize();
    
    $('#popup input').first().focus();
    
    return false;
  });
});

$(window).resize(function() {
  $('#overlay').css({
    height: $(window).height(),
    width: $(window).width()
  });
  
  $('#popup').css({
    left: ($(window).width() - $('#popup').outerWidth()) / 2,
    top: ($(window).height() - $('#popup').outerHeight()) / 2
  });
});