$(window).load(function() {
  $('aside a').first().addClass('selected');
  $('section section').hide();
  $('section section').first().show();
  
  $('aside a').each(function() {
    $(this).attr('href', '/docs' + $(this).attr('href'));
  });
  
  $('aside a').on('click', function() {
    if ($(this).parents('li').length == 1) {
      $('aside a').removeClass('selected');
      $(this).addClass('selected');
      $('section section').hide();
      $('section section').eq($(this).parent().index()).show();
      
      $('body').animate({
        scrollTop: 0
      });
      
    } else if ($(this).parents('li').length == 2) {
      $('aside a').removeClass('selected');
      $(this).addClass('selected');
      $('section section').hide();
      $('section section').eq($(this).parents('li').last().index()).show();
      
      var hash = $(this).attr('href').split('#');
      $('body').animate({
        scrollTop: $('a[name="' + hash[1] + '"]').offset().top - $('header').outerHeight()
      });
    }
    
    return false;
  });
});