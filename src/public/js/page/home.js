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
  $('body').css('backgroundImage', 'url(https://s3.amazonaws.com/crystal-web/img/quartz.jpg)');
  
  setInterval(function() {
    if ($(window).width() < 640) {
      return;
    }
    
    var data, padding, type = $('header').data('type');
    
    if ($(window).scrollTop() <= $(window).height() - 130) {
      if (type == 'expand') {
        return;
      }
      color = '';
      data = 'expand'
      padding = 40;
      
    } else {
      if (type == 'collapse') {
        return;
      }
      color = '#000';
      data = 'collapse'
      padding = 10;
    }
    
    if (type == 'collapse') {
      $('header').css('backgroundColor', color);
    }
    $('header').data('type', data);
    $('header').stop().animate({
      padding: padding
    },{
      complete: function() {
        if (type == 'expand') {
          $('header').css('backgroundColor', color);
        }
        $('header').removeData('animating');
      }
    });
    
  }, 100);
  
  $(window).scroll(function() {
    if ($(window).width() < 640) {
      return;
    }
    
    var opacity = 1 - ($(window).scrollTop() / ($(window).height() - $('header').outerHeight() - 250));
    if (opacity < 0) {
      opacity = 0;
    }
    $('#intro').css('opacity', opacity);
    if (opacity === 0) {
      $('#intro div').hide();
    } else {
      $('#intro div').show();
    }
  });
  
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
  
  $('.image').on('mouseenter', function() {
    $(this).find('.screenshot').css('width', $(this).find('.icon').outerWidth()).fadeIn();
  });
  $('.image').on('mouseleave', function() {
    $(this).find('.screenshot').fadeOut();
  });
  
  $(window).scroll();
});