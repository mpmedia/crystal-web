var api = 'https://api.crystal.sh/';

var Crystal = {
  Color: {
    rgbToHex: function(r, g, b) {
       return ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    },
    random: function() {
      var r = Crystal.Number.random(120, 255);
      var g = Crystal.Number.random(120, 255);
      var b = Crystal.Number.random(120, 255);
      
      return Crystal.Color.rgbToHex(r, g, b);
    }
  },
  Loader: {
    hide: function() {
      Crystal.Popup.hide();
    },
    show: function() {
      Crystal.Popup.show({
        content: 'Loading...'
      });
    }
  },
  Number: {
    random: function(min, max) {
      return Math.floor(Math.random()*(max-min+1)+min);
    }
  },
  Popup: {
    hide: function() {
      $('#overlay, #popup').fadeOut(function() {
        $(this).remove();
      });
    },
    show: function(opts) {
      var overlay = $('#overlay'),
        popup = $('#popup');
        
      if (!overlay.length) {
        overlay = $('<div id="overlay" />');
        overlay.click(Crystal.Popup.hide);
        overlay.hide();
        $('body').append(overlay);
      }
      
      if (!popup.length) {
        popup = $('<div id="popup" />')
        popup.hide();
        $('body').append(popup);
      }
      
      popup.html(opts.content);
      
      $(window).resize();
      
      overlay.fadeIn();
      popup.fadeIn(function() {
        $('#popup input').first().focus();
      });
    }
  }
};

$(document).keydown(function(e) {
  if ($(e.target)[0].tagName == 'INPUT') {
    return;
  }
  
  switch (e.keyCode) {
    case 27: {
      if ($('#popup').length) {
        Crystal.Popup.hide();
      } else {
        $('#content, header').animate({
          width: $(window).width()
        });
        $('#sidebar').animate({
          right: -300
        },{
          complete: function() {
            $(this).removeClass('open');
          }
        });
      }
      break;
    }
    case 85: {
      if ($('#sidebar').hasClass('open')) {
        $('#content, header').animate({
          width: $(window).width()
        });
        $('#sidebar').animate({
          right: -300
        },{
          complete: function() {
            $(this).removeClass('open');
          }
        });
      } else {
        $('#sidebar').addClass('open');
        $('#content, header').animate({
          width: $(window).width() - 300
        });
        $('#sidebar').animate({
          right: 0
        },{
          complete: function() {
            $(this).find('input').first().focus();
          }
        });
      }
      break;
    }
  }
});

$(window).load(function() {
  $('body').css('backgroundImage', 'url(https://s3.amazonaws.com/crystal-web/img/quartz.jpg)');
  
  $('.close').click(function() {
    $('#content, header').animate({
      width: $(window).width()
    });
    $('#sidebar').animate({
      right: -300
    },{
      complete: function() {
        $(this).removeClass('open');
      }
    });
    return false;
  });
  
  /*
  $('.login').click(function() {
    var overlay = $('<div id="overlay" />');
    overlay.click(function() {
      $('#overlay, #popup').fadeOut(function() {
        $(this).remove();
      });
    });
    overlay.hide();
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
    popup.hide();
    $('body').append(popup);
    
    $(window).resize();
    
    $('#overlay, #popup').fadeIn();
    
    $('#popup input').first().focus();
    
    return false;
  });
  */
  
  $('#menu').click(function(e) {
    if ($(e.target).attr('id') == 'menu') {
      $('#crystal').removeClass('menu');
      $('#menu').fadeOut();
    }
  });
  
  $('.menu').click(function() {
    $('#crystal').addClass('menu');
    $('#menu').fadeIn();
    
    $(window).resize();
    
    return false;
  });
  
  $('.signup').click(function() {
    var overlay = $('<div id="overlay" />');
    overlay.click(function() {
      $('#overlay, #popup').fadeOut(function() {
        $(this).remove();
      });
    });
    overlay.hide();
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
    popup.hide();
    $('body').append(popup);
    
    $(window).resize();
    
    $('#overlay, #popup').fadeIn();
    
    $('#popup input').first().focus();
    
    return false;
  });
  
  /*
  $('.login, .user').click(function() {
    if ($('#sidebar').hasClass('open')) {
      $('#content, header').animate({
        width: $(window).width()
      });
      $('#sidebar').animate({
        right: -300
      },{
        complete: function() {
          $(this).removeClass('open');
        }
      });
    } else {
      $('#sidebar').addClass('open');
      $('#content, header').animate({
        width: $(window).width() - 300
      });
      $('#sidebar').animate({
        right: 0
      },{
        complete: function() {
          $(this).find('input').first().focus();
        }
      });
    }
    return false;
  });
  */
  
  $(window).resize();
});

$(window).resize(function() {
  $('#menu').css({
    height: $(window).height(),
    width: $(window).width()
  });
  
  $('#menu div').css({
    left: ($(window).width() - $('#menu div').outerWidth()) / 2,
    top: ($(window).height() - $('#menu div').outerHeight()) / 2
  });
  
  $('#overlay').css({
    height: $(window).height(),
    width: $(window).width()
  });
  
  $('#popup').css({
    left: ($(window).width() - $('#popup').outerWidth()) / 2,
    top: ($(window).height() - $('#popup').outerHeight()) / 2
  });
  
  $('#sidebar').css('minHeight', $(window).height());
  
  if ($('#sidebar').hasClass('open')) {
    $('#content, header').css({
      width: $(window).width() - 300
    });
  } else {
    $('#content, header').css({
      width: $(window).width()
    });
  }
});